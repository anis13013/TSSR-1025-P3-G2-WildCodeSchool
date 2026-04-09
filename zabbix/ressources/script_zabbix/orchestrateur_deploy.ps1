################################################################################
# Script : orchestrateur_deploy.ps1
# Description : Orchestrateur de deploiement Zabbix Agent pour infra TSSR
# Version : 5.0 - PRODUCTION FINALE
# Date : 2026-02-07
#
# Architecture Zabbix :
# - Serveur Zabbix : 10.20.20.12 (VLAN 220) - Pour machines LAN
# - Proxy Zabbix   : 10.20.20.13 (VLAN 220) - Pour machines DMZ
# - PC Admin       : 10.20.10.3 (VLAN 210)
#
# Specificites :
# - SSH User       : gx-anboutaleb
# - Cles SSH       : ed25519
# - Windows SSH    : port 22222 (prioritaire) ou WinRM fallback
# - Linux SSH      : port 22
# - PSK            : Gestion manuelle (creer les fichiers dans psk/)
################################################################################

$ErrorActionPreference = "Stop"

# ============================================================================
# VARIABLES GLOBALES
# ============================================================================

# ============================================================================
# VARIABLES GLOBALES
# ============================================================================

$Global:ZABBIX_VERSION = if ($env:ZABBIX_VERSION) { $env:ZABBIX_VERSION } else { "7.4" }

$Global:WORKDIR = $PSScriptRoot
$Global:NETWORK_INFO_DIR = Join-Path $WORKDIR "network_info"
$Global:SCRIPTS_DIR = $WORKDIR
$Global:LOGS_DIR = Join-Path $WORKDIR "logs"
$Global:REPORTS_DIR = Join-Path $WORKDIR "reports"
$Global:PSK_DIR = Join-Path $WORKDIR "psk"

@($Global:LOGS_DIR, $Global:REPORTS_DIR, $Global:PSK_DIR) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

$Global:TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"
$Global:REPORT_FILE = Join-Path $Global:REPORTS_DIR "deployment_report_$Global:TIMESTAMP.json"
$Global:REPORT_TEMP = "$Global:REPORT_FILE.tmp"

# Credentials SSH (ed25519) - UTILISATEUR DYNAMIQUE selon OS
$Global:SSH_KEY = if ($env:SSH_KEY) { $env:SSH_KEY } else { "$HOME\.ssh\id_ed25519" }

# Credentials WinRM (fallback)
$Global:WINRM_USER = if ($env:WINRM_USER) { $env:WINRM_USER } else { "administrator" }
$Global:WINRM_PASSWORD = $null

# Configuration
$Global:AGENT_TYPE = "agent2"

# ============================================================================
# FONCTIONS UTILITAIRES
# ============================================================================

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "ERROR"   { "Red" }
        "WARNING" { "Yellow" }
        "SUCCESS" { "Green" }
        default   { "White" }
    }
    
    $prefix = switch ($Level) {
        "ERROR"   { "[X]" }
        "WARNING" { "[!]" }
        "SUCCESS" { "[OK]" }
        default   { "[INFO]" }
    }
    
    Write-Host "[$timestamp] $prefix $Message" -ForegroundColor $color
}

function Test-Prerequisites {
    Write-Log "Verification des prerequis..." -Level INFO
    
    $missing = @()
    
    if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) { $missing += "ssh" }
    if (-not (Get-Command scp -ErrorAction SilentlyContinue)) { $missing += "scp" }
    
    if ($missing.Count -gt 0) {
        Write-Log "Outils manquants : $($missing -join ', ')" -Level ERROR
        Write-Log "Installation OpenSSH : Settings > Apps > Optional Features" -Level INFO
        return $false
    }
    
    if (-not (Test-Path $Global:SSH_KEY)) {
        Write-Log "Cle SSH manquante : $Global:SSH_KEY" -Level WARNING
        Write-Log "Generer avec : ssh-keygen -t ed25519" -Level INFO
    }
    
    if (-not (Test-Path $Global:NETWORK_INFO_DIR)) {
        Write-Log "Repertoire network_info manquant" -Level ERROR
        return $false
    }
    
    Write-Log "Prerequis valides" -Level SUCCESS
    return $true
}

function Get-Inventory {
    $file = Join-Path $Global:NETWORK_INFO_DIR "hosts.json"
    
    if (-not (Test-Path $file)) {
        Write-Log "Inventaire non trouve : $file" -Level ERROR
        return $null
    }
    
    try {
        $inventory = Get-Content $file -Raw | ConvertFrom-Json
        Write-Log "Inventaire charge" -Level SUCCESS
        return $inventory
    }
    catch {
        Write-Log "Erreur lecture JSON : $_" -Level ERROR
        return $null
    }
}

function Test-IPConflicts {
    param([object]$Inventory)
    
    Write-Log "Verification conflits IP..." -Level INFO
    
    $ips = $Inventory.hosts | Select-Object -ExpandProperty ip
    $duplicates = $ips | Group-Object | Where-Object { $_.Count -gt 1 } | Select-Object -ExpandProperty Name
    
    if ($duplicates) {
        Write-Log "CONFLIT IP detecte :" -Level ERROR
        $duplicates | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
        return $false
    }
    
    Write-Log "Aucun conflit IP" -Level SUCCESS
    return $true
}

function Get-PSKFile {
    param([string]$Hostname)
    
    $pskFile = Join-Path $Global:PSK_DIR "$Hostname.psk"
    
    if (Test-Path $pskFile) {
        Write-Log "PSK trouve pour $Hostname" -Level SUCCESS
        return $pskFile
    }
    else {
        Write-Log "Aucun PSK pour $Hostname (installation sans chiffrement)" -Level WARNING
        return $null
    }
}

function Test-Connectivity {
    param(
        [string]$IP,
        [int]$Port = 22
    )
    
    if (-not (Test-Connection -ComputerName $IP -Count 2 -Quiet -ErrorAction SilentlyContinue)) {
        Write-Log "Hote injoignable (ping) : $IP" -Level ERROR
        return $false
    }
    
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $connect = $tcp.BeginConnect($IP, $Port, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne(5000, $false)
        
        if ($wait) {
            $tcp.EndConnect($connect)
            $tcp.Close()
            Write-Log "Connectivite OK : ${IP}:${Port}" -Level SUCCESS
            return $true
        }
        else {
            $tcp.Close()
            Write-Log "Port $Port ferme sur $IP" -Level WARNING
            return $false
        }
    }
    catch {
        Write-Log "Port $Port inaccessible sur $IP" -Level WARNING
        return $false
    }
}

# ============================================================================
# DEPLOIEMENT LINUX
# ============================================================================

function Deploy-Linux {
    param(
        [string]$Hostname,
        [string]$IP,
        [string]$ZabbixServer,
        [string]$SSHUser = "root",
        [int]$SSHPort = 22,
        [string]$Mode = "install",
        [string]$AgentType = "agent2"
    )
    
    Write-Log "Deploiement Linux sur $Hostname (${SSHUser}@${IP}:${SSHPort}) -> Zabbix: $ZabbixServer" -Level INFO
    
    if (-not (Test-Connectivity -IP $IP -Port $SSHPort)) {
        @{hostname=$Hostname; ip=$IP; status="unreachable"; error="SSH unreachable"} | 
            ConvertTo-Json -Compress | Add-Content $Global:REPORT_TEMP
        "," | Add-Content $Global:REPORT_TEMP
        return $false
    }
    
    $scriptName = "install_zabbix_agent_debian.sh"
    $localScript = Join-Path $Global:SCRIPTS_DIR $scriptName
    $remoteScript = "/tmp/$scriptName"
    
    if (-not (Test-Path $localScript)) {
        Write-Log "Script non trouve : $localScript" -Level ERROR
        return $false
    }
    
    Write-Log "Copie script..." -Level INFO
    
    $scpArgs = @("-i", $Global:SSH_KEY, "-P", $SSHPort, "-o", "StrictHostKeyChecking=no", $localScript, "${SSHUser}@${IP}:${remoteScript}")
    $scp = Start-Process -FilePath "scp" -ArgumentList $scpArgs -NoNewWindow -Wait -PassThru
    
    if ($scp.ExitCode -ne 0) {
        Write-Log "Echec copie script" -Level ERROR
        return $false
    }
    
    $pskFile = Get-PSKFile -Hostname $Hostname
    $pskIdentity = ""
    $usePSK = "no"
    
    if ($pskFile) {
        $remotePSK = "/tmp/${Hostname}.psk"
        $scpPSK = @("-i", $Global:SSH_KEY, "-P", $SSHPort, "-o", "StrictHostKeyChecking=no", $pskFile, "${SSHUser}@${IP}:${remotePSK}")
        $scpResult = Start-Process -FilePath "scp" -ArgumentList $scpPSK -NoNewWindow -Wait -PassThru
        
        if ($scpResult.ExitCode -eq 0) {
            $pskIdentity = "PSK:${Hostname}"
            $usePSK = "yes"
            Write-Log "PSK copie pour $Hostname" -Level SUCCESS
        }
        else {
            Write-Log "Echec copie PSK, installation sans chiffrement" -Level WARNING
        }
    }
    
    Write-Log "Execution du script..." -Level INFO
    
    $envVars = @(
        "ZABBIX_VERSION=$Global:ZABBIX_VERSION",
        "ZABBIX_SERVER=$ZabbixServer",
        "HOSTNAME=$Hostname",
        "MODE=$Mode",
        "AGENT_TYPE=$AgentType"
    )
    
    if ($usePSK -eq "yes") {
        $envVars += @("USE_PSK=yes", "PSK_FILE=/tmp/${Hostname}.psk", "PSK_IDENTITY=$pskIdentity")
    } else {
        $envVars += "USE_PSK=no"
    }
    
    $remoteCmd = ($envVars -join ' ') + " bash $remoteScript"
    $sshArgs = @("-i", $Global:SSH_KEY, "-p", $SSHPort, "-o", "StrictHostKeyChecking=no", "${SSHUser}@${IP}", $remoteCmd)
    $ssh = Start-Process -FilePath "ssh" -ArgumentList $sshArgs -NoNewWindow -Wait -PassThru
    
    if ($ssh.ExitCode -eq 0) {
        Write-Log "Deploiement reussi" -Level SUCCESS
        @{hostname=$Hostname; ip=$IP; zabbix_server=$ZabbixServer; psk_enabled=$usePSK; status="success"} | 
            ConvertTo-Json -Compress | Add-Content $Global:REPORT_TEMP
        "," | Add-Content $Global:REPORT_TEMP
        return $true
    }
    else {
        Write-Log "Echec deploiement" -Level ERROR
        @{hostname=$Hostname; ip=$IP; status="failed"} | 
            ConvertTo-Json -Compress | Add-Content $Global:REPORT_TEMP
        "," | Add-Content $Global:REPORT_TEMP
        return $false
    }
}


# ============================================================================
# DEPLOIEMENT WINDOWS
# ============================================================================

function Deploy-Windows {
    param(
        [string]$Hostname,
        [string]$IP,
        [string]$ZabbixServer,
        [string]$SSHUser = "administrator",
        [int]$SSHPort = 22222,
        [string]$Mode = "install"
    )
    
    Write-Log "Deploiement Windows sur $Hostname ($IP) -> Zabbix: $ZabbixServer" -Level INFO
    
    if (Test-Connectivity -IP $IP -Port $SSHPort) {
        Write-Log "SSH disponible sur port $SSHPort" -Level INFO
        return Deploy-Windows-SSH -Hostname $Hostname -IP $IP -ZabbixServer $ZabbixServer -SSHUser $SSHUser -SSHPort $SSHPort -Mode $Mode
    }
    
    Write-Log "SSH non disponible, tentative WinRM..." -Level WARNING
    if (Test-Connectivity -IP $IP -Port 5985) {
        Write-Log "WinRM disponible" -Level INFO
        return Deploy-Windows-WinRM -Hostname $Hostname -IP $IP -ZabbixServer $ZabbixServer -Mode $Mode
    }
    
    Write-Log "Aucune methode de connexion disponible" -Level ERROR
    @{hostname=$Hostname; ip=$IP; status="unreachable"} | 
        ConvertTo-Json -Compress | Add-Content $Global:REPORT_TEMP
    "," | Add-Content $Global:REPORT_TEMP
    return $false
}

function Deploy-Windows-SSH {
    param(
        [string]$Hostname,
        [string]$IP,
        [string]$ZabbixServer,
        [string]$SSHUser = "administrator",
        [int]$SSHPort,
        [string]$Mode
    )
    
    Write-Log "Deploiement Windows via SSH (${SSHUser}@${IP}:${SSHPort})..." -Level INFO
    
    $psScript = Join-Path $Global:SCRIPTS_DIR "install_zabbix_agent_windows.ps1"
    
    if (-not (Test-Path $psScript)) {
        Write-Log "Script Windows non trouve" -Level ERROR
        return $false
    }
    
    $remoteScript = "C:\Temp\install_zabbix_agent_windows.ps1"
    $remoteWrapper = "C:\Temp\run_install.ps1"
    
    Write-Log "Creation repertoire distant..." -Level INFO
    $mkdirCmd = "if not exist C:\Temp mkdir C:\Temp"
    $sshMkdir = @("-i", $Global:SSH_KEY, "-p", $SSHPort, "-o", "StrictHostKeyChecking=no", "${SSHUser}@${IP}", $mkdirCmd)
    Start-Process -FilePath "ssh" -ArgumentList $sshMkdir -NoNewWindow -Wait -PassThru | Out-Null
    
    Write-Log "Copie script PowerShell..." -Level INFO
    $scpArgs = @("-i", $Global:SSH_KEY, "-P", $SSHPort, "-o", "StrictHostKeyChecking=no", $psScript, "${SSHUser}@${IP}:${remoteScript}")
    $scp = Start-Process -FilePath "scp" -ArgumentList $scpArgs -NoNewWindow -Wait -PassThru
    
    if ($scp.ExitCode -ne 0) {
        Write-Log "Echec copie script" -Level ERROR
        return $false
    }
    
    $pskFile = Get-PSKFile -Hostname $Hostname
    $usePSK = "no"
    $pskIdentity = "PSK:${Hostname}"
    
    # Créer le wrapper script localement
    $wrapperContent = @"
`$env:ZABBIX_VERSION = '$Global:ZABBIX_VERSION'
`$env:ZABBIX_SERVER = '$ZabbixServer'
`$env:HOSTNAME = '$Hostname'
`$env:MODE = '$Mode'
`$env:USE_PSK = '$usePSK'
"@

    if ($pskFile) {
        $pskContent = Get-Content $pskFile -Raw
        $pskContent = $pskContent.Trim()
        $usePSK = "yes"
        
        # Ajouter PSK au wrapper
        $wrapperContent += @"

`$env:USE_PSK = 'yes'
`$env:PSK_IDENTITY = '$pskIdentity'
`$env:PSK_CONTENT = '$pskContent'
"@
        Write-Log "PSK charge pour $Hostname" -Level SUCCESS
    }
    
    # Ajouter l'appel au script principal
    $wrapperContent += @"

& 'C:\Temp\install_zabbix_agent_windows.ps1'
"@

    # Sauvegarder le wrapper localement
    $localWrapper = Join-Path $env:TEMP "run_install_${Hostname}.ps1"
    $wrapperContent | Set-Content -Path $localWrapper -Encoding UTF8
    
    Write-Log "Copie wrapper script..." -Level INFO
    $scpWrapper = @("-i", $Global:SSH_KEY, "-P", $SSHPort, "-o", "StrictHostKeyChecking=no", $localWrapper, "${SSHUser}@${IP}:${remoteWrapper}")
    $scpW = Start-Process -FilePath "scp" -ArgumentList $scpWrapper -NoNewWindow -Wait -PassThru
    
    if ($scpW.ExitCode -ne 0) {
        Write-Log "Echec copie wrapper" -Level ERROR
        return $false
    }
    
    # Supprimer le wrapper local
    Remove-Item $localWrapper -Force -ErrorAction SilentlyContinue
    
    Write-Log "Execution PowerShell a distance..." -Level INFO
    
    # Commande simplifiée : juste exécuter le wrapper
    $remoteExec = "powershell -ExecutionPolicy Bypass -File C:\Temp\run_install.ps1"
    
    $sshExec = @("-i", $Global:SSH_KEY, "-p", $SSHPort, "-o", "StrictHostKeyChecking=no", "${SSHUser}@${IP}", $remoteExec)
    $ssh = Start-Process -FilePath "ssh" -ArgumentList $sshExec -NoNewWindow -Wait -PassThru
    
    if ($ssh.ExitCode -eq 0) {
        Write-Log "Deploiement Windows (SSH) reussi" -Level SUCCESS
        @{hostname=$Hostname; ip=$IP; zabbix_server=$ZabbixServer; psk_enabled=$usePSK; status="success"; method="SSH"} | 
            ConvertTo-Json -Compress | Add-Content $Global:REPORT_TEMP
        "," | Add-Content $Global:REPORT_TEMP
        return $true
    }
    else {
        Write-Log "Echec deploiement Windows (SSH)" -Level ERROR
        @{hostname=$Hostname; ip=$IP; status="failed"; method="SSH"; exit_code=$ssh.ExitCode} | 
            ConvertTo-Json -Compress | Add-Content $Global:REPORT_TEMP
        "," | Add-Content $Global:REPORT_TEMP
        return $false
    }
}


function Deploy-Windows-WinRM {
    param(
        [string]$Hostname,
        [string]$IP,
        [string]$ZabbixServer,
        [string]$Mode
    )
    
    Write-Log "Deploiement Windows via WinRM..." -Level INFO
    
    $psScript = Join-Path $Global:SCRIPTS_DIR "install_zabbix_agent_windows.ps1"
    
    if (-not (Test-Path $psScript)) {
        Write-Log "Script Windows non trouve" -Level ERROR
        return $false
    }
    
    $pskFile = Get-PSKFile -Hostname $Hostname
    $pskContent = ""
    $usePSK = "no"
    
    if ($pskFile) {
        $pskContent = Get-Content $pskFile -Raw
        $usePSK = "yes"
    }
    
    if (-not $Global:WINRM_PASSWORD) {
        $Global:WINRM_PASSWORD = Read-Host "Mot de passe ${Global:WINRM_USER}@${Hostname}" -AsSecureString
    }
    
    $cred = New-Object System.Management.Automation.PSCredential($Global:WINRM_USER, $Global:WINRM_PASSWORD)
    
    try {
        $sessionParams = @{ComputerName=$IP; Credential=$cred; ErrorAction="Stop"}
        
        try {
            $session = New-PSSession @sessionParams
        }
        catch {
            $sessionParams['UseSSL'] = $true
            $sessionParams['SessionOption'] = New-PSSessionOption -SkipCACheck -SkipCNCheck
            $session = New-PSSession @sessionParams
        }
        
        $scriptContent = Get-Content $psScript -Raw
        
        Invoke-Command -Session $session -ScriptBlock {
            param($Script, $Ver, $Srv, $Host, $Mode, $PSK, $PSKContent)
            
            Set-Variable -Name "env:ZABBIX_VERSION" -Value $Ver
            Set-Variable -Name "env:ZABBIX_SERVER" -Value $Srv
            Set-Variable -Name "env:HOSTNAME" -Value $Host
            Set-Variable -Name "env:MODE" -Value $Mode
            Set-Variable -Name "env:USE_PSK" -Value $PSK
            
            if ($PSK -eq "yes") {
                Set-Variable -Name "env:PSK_CONTENT" -Value $PSKContent
                Set-Variable -Name "env:PSK_IDENTITY" -Value "PSK:$Host"
            }
            
            Invoke-Expression $Script
        } -ArgumentList $scriptContent, $Global:ZABBIX_VERSION, $ZabbixServer, $Hostname, $Mode, $usePSK, $pskContent
        
        Remove-PSSession $session
        
        Write-Log "Deploiement Windows (WinRM) reussi" -Level SUCCESS
        @{hostname=$Hostname; ip=$IP; zabbix_server=$ZabbixServer; psk_enabled=$usePSK; status="success"; method="WinRM"} | 
            ConvertTo-Json -Compress | Add-Content $Global:REPORT_TEMP
        "," | Add-Content $Global:REPORT_TEMP
        return $true
    }
    catch {
        Write-Log "Echec WinRM : $_" -Level ERROR
        @{hostname=$Hostname; ip=$IP; status="failed"; method="WinRM"} | 
            ConvertTo-Json -Compress | Add-Content $Global:REPORT_TEMP
        "," | Add-Content $Global:REPORT_TEMP
        return $false
    }
}

# ============================================================================
# MENU
# ============================================================================

function Show-Menu {
    Clear-Host
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "   ORCHESTRATEUR DEPLOIEMENT ZABBIX - INFRASTRUCTURE TSSR     " -ForegroundColor Cyan
    Write-Host "                                                              " -ForegroundColor Cyan
    Write-Host "  Version Zabbix : $Global:ZABBIX_VERSION                    " -ForegroundColor Cyan
    Write-Host "  SSH User       : $Global:SSH_USER                          " -ForegroundColor Cyan
    Write-Host "  Cle SSH        : ed25519                                   " -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " 1. Verifier l'inventaire reseau"
    Write-Host " 2. Deployer agent Linux (Debian/Ubuntu)"
    Write-Host " 3. Deployer agent Windows (SSH/WinRM)"
    Write-Host " 4. Deploiement complet (tous les hotes)"
    Write-Host " 5. Mode DRY-RUN (simulation)"
    Write-Host " 6. Reparation/Verification"
    Write-Host " 7. Afficher rapport de deploiement"
    Write-Host " 8. Configuration avancee"
    Write-Host " 0. Quitter"
    Write-Host ""
    
    return Read-Host "Choisissez une option"
}

function Show-AdvancedConfig {
    Clear-Host
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "                 CONFIGURATION AVANCEE                         " -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Configuration actuelle :"
    Write-Host " - Version Zabbix    : $Global:ZABBIX_VERSION"
    Write-Host " - SSH User          : $Global:SSH_USER"
    Write-Host " - Type d'agent      : $Global:AGENT_TYPE"
    Write-Host ""
    
    $new = Read-Host "Nouvelle version Zabbix (7.0/7.2/7.4) [Entree=conserver]"
    if ($new) { $Global:ZABBIX_VERSION = $new }
    
    $new = Read-Host "Type agent (agent2/agent) [Entree=$Global:AGENT_TYPE]"
    if ($new) { $Global:AGENT_TYPE = $new }
    
    Write-Log "Configuration mise a jour" -Level SUCCESS
    Start-Sleep 2
}

function Deploy-All {
    param([string]$Mode = "install")
    
    Write-Log "Deploiement complet - Mode : $Mode" -Level INFO
    
    $inventory = Get-Inventory
    if (-not $inventory) { return }
    
    $total = 0; $success = 0; $failed = 0
    
    "[" | Set-Content $Global:REPORT_TEMP
    
    foreach ($targetHost in $inventory.hosts) {
        $total++
        
        $hostname = $targetHost.hostname
        $ip = $targetHost.ip
        $os = if ($targetHost.os) { $targetHost.os } else { "linux" }
        $sshPort = if ($targetHost.ssh_port) { $targetHost.ssh_port } else { 22 }
        $sshUser = if ($targetHost.ssh_user) { $targetHost.ssh_user } else { if ($os -eq "windows") { "administrator" } else { "root" } }
        $zabbixServer = if ($targetHost.zabbix_server) { $targetHost.zabbix_server } else { "10.20.20.12" }
        
        Write-Log "[$total] $hostname (${sshUser}@${ip}:${sshPort}) - OS: $os - Zabbix: $zabbixServer" -Level INFO
        
        if ($os -eq "windows") {
            if (Deploy-Windows -Hostname $hostname -IP $ip -ZabbixServer $zabbixServer -SSHUser $sshUser -SSHPort $sshPort -Mode $Mode) {
                $success++
            } else { $failed++ }
        }
        else {
            if (Deploy-Linux -Hostname $hostname -IP $ip -ZabbixServer $zabbixServer -SSHUser $sshUser -SSHPort $sshPort -Mode $Mode -AgentType $Global:AGENT_TYPE) {
                $success++
            } else { $failed++ }
        }
        
        Start-Sleep 2
    }
    
    $content = Get-Content $Global:REPORT_TEMP -Raw
    $content = $content.TrimEnd(",`r`n") + "`n]"
    $content | Set-Content $Global:REPORT_FILE
    Remove-Item $Global:REPORT_TEMP -Force -ErrorAction SilentlyContinue
    
    Write-Host ""
    Write-Log "=========================================" -Level INFO
    Write-Log "Deploiement termine !" -Level SUCCESS
    Write-Log "Total   : $total" -Level INFO
    Write-Log "Succes  : $success" -Level SUCCESS
    Write-Log "Echecs  : $failed" -Level ERROR
    Write-Log "Rapport : $Global:REPORT_FILE" -Level INFO
    Write-Log "=========================================" -Level INFO
}

# ============================================================================
# MAIN
# ============================================================================

function Main {
    if (-not (Test-Prerequisites)) {
        Read-Host "Appuyez sur Entree pour quitter"
        exit 1
    }
    
    $inventory = Get-Inventory
    if (-not $inventory) {
        Read-Host "Appuyez sur Entree pour quitter"
        exit 1
    }
    
    if (-not (Test-IPConflicts -Inventory $inventory)) {
        Read-Host "Appuyez sur Entree pour quitter"
        exit 1
    }
    
    while ($true) {
        $choice = Show-Menu
        
        switch ($choice) {
            "1" {
                Write-Log "Affichage inventaire..." -Level INFO
                Get-Content (Join-Path $Global:NETWORK_INFO_DIR "hosts.json") | ConvertFrom-Json | ConvertTo-Json -Depth 10
                Read-Host "Entree pour continuer"
            }
            
           # Dans Main() - Option 2
"2" {
    $h = Read-Host "Hostname (ex: ECO-BDX-EX07)"
    $target = $inventory.hosts | Where-Object { $_.hostname -eq $h }
    if ($target) {
        $port = if ($target.ssh_port) { $target.ssh_port } else { 22 }
        $user = if ($target.ssh_user) { $target.ssh_user } else { "root" }
        $zabbix = if ($target.zabbix_server) { $target.zabbix_server } else { "10.20.20.12" }
        Deploy-Linux -Hostname $h -IP $target.ip -ZabbixServer $zabbix -SSHUser $user -SSHPort $port -Mode "install" -AgentType $Global:AGENT_TYPE
    } else {
        Write-Log "Hote non trouve" -Level ERROR
    }
    Read-Host "Entree"
}

"3" {
    $h = Read-Host "Hostname (ex: ECO-BDX-EX01)"
    $target = $inventory.hosts | Where-Object { $_.hostname -eq $h }
    if ($target) {
        $port = if ($target.ssh_port) { $target.ssh_port } else { 22222 }
        $user = if ($target.ssh_user) { $target.ssh_user } else { "administrator" }
        $zabbix = if ($target.zabbix_server) { $target.zabbix_server } else { "10.20.20.12" }
        Deploy-Windows -Hostname $h -IP $target.ip -ZabbixServer $zabbix -SSHUser $user -SSHPort $port -Mode "install"
    } else {
        Write-Log "Hote non trouve" -Level ERROR
    }
    Read-Host "Entree"
}
            
            "4" {
                if ((Read-Host "Deploiement complet - Confirmer (y/n)") -eq "y") {
                    Deploy-All -Mode "install"
                }
                Read-Host "Entree"
            }
            
            "5" {
                Write-Log "Mode DRY-RUN (simulation)" -Level WARNING
                Deploy-All -Mode "dry-run"
                Read-Host "Entree"
            }
            
            "6" {
                $h = Read-Host "Hostname pour reparation"
                $target = $inventory.hosts | Where-Object { $_.hostname -eq $h }
                if ($target) {
                    $os = if ($target.os) { $target.os } else { "linux" }
                    $port = if ($target.ssh_port) { $target.ssh_port } else { 22 }
                    $zabbix = if ($target.zabbix_server) { $target.zabbix_server } else { "10.20.20.12" }
                    
                    if ($os -eq "windows") {
                        Deploy-Windows -Hostname $h -IP $target.ip -ZabbixServer $zabbix -SSHPort $port -Mode "repair"
                    } else {
                        Deploy-Linux -Hostname $h -IP $target.ip -ZabbixServer $zabbix -SSHPort $port -Mode "repair" -AgentType $Global:AGENT_TYPE
                    }
                } else {
                    Write-Log "Hote non trouve" -Level ERROR
                }
                Read-Host "Entree"
            }
            
            "7" {
                if (Test-Path $Global:REPORT_FILE) {
                    Get-Content $Global:REPORT_FILE | ConvertFrom-Json | ConvertTo-Json -Depth 10
                } else {
                    Write-Log "Aucun rapport disponible" -Level WARNING
                }
                Read-Host "Entree"
            }
            
            "8" { Show-AdvancedConfig }
            
            "0" {
                Write-Log "Au revoir !" -Level INFO
                exit 0
            }
            
            default {
                Write-Log "Option invalide" -Level ERROR
                Start-Sleep 1
            }
        }
    }
}

Main
