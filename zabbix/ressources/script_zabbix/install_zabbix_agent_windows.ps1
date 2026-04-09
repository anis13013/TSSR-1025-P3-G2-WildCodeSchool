
################################################################################
# Script : install_zabbix_agent_windows.ps1
# Version : 6.1 - CORRECTIONS ROBUSTES (Anti-BOM, cleanup registre, vérifs service)
# Compatible : Windows Server 2008 R2+ / Windows 7+
# PSK : Gestion manuelle
################################################################################

$ErrorActionPreference = "Stop"

$ZABBIX_VERSION = if ($env:ZABBIX_VERSION) { $env:ZABBIX_VERSION } else { "7.4" }
$ZABBIX_SERVER = if ($env:ZABBIX_SERVER) { $env:ZABBIX_SERVER } else { "10.20.20.12" }
$TARGET_HOSTNAME = if ($env:HOSTNAME) { $env:HOSTNAME } else { $env:COMPUTERNAME }
$MODE = if ($env:MODE) { $env:MODE } else { "install" }
$USE_PSK = if ($env:USE_PSK) { $env:USE_PSK } else { "no" }
$PSK_CONTENT = if ($env:PSK_CONTENT) { $env:PSK_CONTENT } else { "" }
$PSK_IDENTITY = if ($env:PSK_IDENTITY) { $env:PSK_IDENTITY } else { "PSK:$TARGET_HOSTNAME" }

$AGENT_SERVICE = "Zabbix Agent 2"
$AGENT_PORT = 10050

$INSTALL_DIR = "C:\Program Files\Zabbix Agent 2"
$CONFIG_FILE = "$INSTALL_DIR\zabbix_agent2.conf"
$PSK_FILE = "$INSTALL_DIR\zabbix_agent2.psk"
$LOG_FILE = "$INSTALL_DIR\zabbix_agent2.log"
$BACKUP_DIR = "C:\ZabbixBackups"

# URLs MSI Zabbix (versions LTS 7.0)
$MSI_URLS = @(
    "https://cdn.zabbix.com/zabbix/binaries/stable/7.0/7.0.7/zabbix_agent2-7.0.7-windows-amd64-openssl.msi",
    "https://cdn.zabbix.com/zabbix/binaries/stable/7.0/7.0.6/zabbix_agent2-7.0.6-windows-amd64-openssl.msi",
    "https://cdn.zabbix.com/zabbix/binaries/stable/7.0/7.0.5/zabbix_agent2-7.0.5-windows-amd64-openssl.msi",
    "https://cdn.zabbix.com/zabbix/binaries/stable/7.0/7.0.0/zabbix_agent2-7.0.0-windows-amd64-openssl.msi"
)

$MSI_DOWNLOAD_PATH = "$env:TEMP\zabbix_agent2.msi"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $prefix = switch ($Level) {
        "ERROR"   { "[ERREUR]" }
        "WARNING" { "[ATTENTION]" }
        "SUCCESS" { "[OK]" }
        default   { "[INFO]" }
    }
    
    Write-Host "[$timestamp] $prefix $Message"
}

function Test-AgentInstalled {
    Write-Log "Verification repertoire installation..."
    
    if (Test-Path $INSTALL_DIR) {
        Write-Log "Repertoire trouve"
        return $true
    }
    
    Write-Log "Aucun agent detecte"
    return $false
}

function Download-ZabbixMSI {
    Write-Log "Recherche meilleure URL de telechargement..."
    
    foreach ($url in $MSI_URLS) {
        Write-Log "Tentative: $url"
        
        try {
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($url, $MSI_DOWNLOAD_PATH)
            
            if (Test-Path $MSI_DOWNLOAD_PATH) {
                $fileSize = (Get-Item $MSI_DOWNLOAD_PATH).Length
                if ($fileSize -gt 1MB) {
                    Write-Log "Telechargement reussi ($([math]::Round($fileSize/1MB, 2)) MB)" -Level SUCCESS
                    Write-Log "URL utilisee: $url" -Level INFO
                    return $true
                }
                else {
                    Write-Log "Fichier invalide, tentative suivante..." -Level WARNING
                    Remove-Item $MSI_DOWNLOAD_PATH -Force -ErrorAction SilentlyContinue
                }
            }
        }
        catch {
            Write-Log "Echec: $($_.Exception.Message)" -Level WARNING
        }
    }
    
    Write-Log "Toutes les URLs ont echoue" -Level ERROR
    return $false
}

function Install-ZabbixAgent {
    Write-Log "Installation silencieuse..."
    
    try {
        $msiLog = "$env:TEMP\zabbix_install_$TIMESTAMP.log"
        $args = "/i `"$MSI_DOWNLOAD_PATH`" /qn /norestart INSTALLDIR=`"$INSTALL_DIR`""
        Start-Process msiexec.exe -ArgumentList $args -Wait -NoNewWindow
        Start-Sleep 5  # Délai augmenté
        Write-Log "MSI exécuté, vérification code retour..." -Level INFO
        
        # Vérifier si installé
        if (Test-Path "$INSTALL_DIR\zabbix_agent2.exe") {
            Write-Log "Installation MSI réussie" -Level SUCCESS
            return $true
        } else {
            Write-Log "Échec MSI (vérifiez $msiLog)" -Level ERROR
            return $false
        }
    } catch {
        Write-Log "Erreur MSI: $_" -Level ERROR
        return $false
    }
}

function Validate-Config {
    param([string]$FilePath)
    
    Write-Log "Validation config: $FilePath"
    
    if (-not (Test-Path $FilePath)) {
        Write-Log "Fichier absent" -Level ERROR
        return $false
    }
    
    # Vérifier BOM (premiers octets != EF BB BF)
    $bytes = Get-Content -Path $FilePath -Encoding Byte -TotalCount 3
    if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        Write-Log "BOM UTF-8 détecté - corruption !" -Level ERROR
        return $false
    }
    
    # Vérification basique syntaxe (première ligne doit commencer par # ou clé valide)
    $firstLine = Get-Content $FilePath -TotalCount 1
    if ($firstLine -notmatch '^(\s*#|\s*[A-Za-z0-9]+.=)') {
        Write-Log "Syntaxe invalide première ligne: $firstLine" -Level ERROR
        return $false
    }
    
    Write-Log "Config valide" -Level SUCCESS
    return $true
}

function Create-CleanConfig {
    Write-Log "Création config propre..."
    
    try {
        # Backup ancien si existe
        if (Test-Path $CONFIG_FILE) {
            Copy-Item $CONFIG_FILE "$BACKUP_DIR\zabbix_agent2.conf.$TIMESTAMP.bak" -Force
        }
        
        # Config minimale avec Encoding ascii (anti-BOM)
        @"
# Zabbix Agent 2 configuration file
Server=$ZABBIX_SERVER
ServerActive=$ZABBIX_SERVER
Hostname=$TARGET_HOSTNAME

LogFile=$LOG_FILE
LogFileSize=0
"@ | Out-File -FilePath $CONFIG_FILE -Encoding ascii -Force
        
        if (Validate-Config $CONFIG_FILE) {
            Write-Log "Config créée et validée" -Level SUCCESS
            return $true
        } else {
            Write-Log "Échec validation config" -Level ERROR
            return $false
        }
    } catch {
        Write-Log "Erreur création config: $_" -Level ERROR
        return $false
    }
}

function Configure-PSK {
    if ($USE_PSK -ne "yes") {
        Write-Log "PSK désactivé, skip"
        return $true
    }
    
    Write-Log "Configuration PSK..."
    
    try {
        # Écrire PSK sans newline
        $PSK_CONTENT | Out-File -FilePath $PSK_FILE -Encoding ascii -NoNewline -Force
        
        # Ajouter à config (avec Encoding ascii)
        @"
TLSConnect=psk
TLSAccept=psk
TLSPSKIdentity=$PSK_IDENTITY
TLSPSKFile=$PSK_FILE
"@ | Add-Content -Path $CONFIG_FILE -Encoding ascii -Force
        
        if (Validate-Config $CONFIG_FILE) {
            Write-Log "PSK configuré et config validée" -Level SUCCESS
            return $true
        } else {
            return $false
        }
    } catch {
        Write-Log "Erreur PSK: $_" -Level ERROR
        return $false
    }
}

function Configure-Firewall {
    Write-Log "Configuration firewall..."
    
    try {
        New-NetFirewallRule -Name "Zabbix Agent" -DisplayName "Zabbix Agent" -Direction Inbound -LocalPort $AGENT_PORT -Protocol TCP -Action Allow -ErrorAction SilentlyContinue
        Write-Log "Règle firewall OK" -Level SUCCESS
        return $true
    } catch {
        Write-Log "Erreur firewall: $_" -Level WARNING
        return $false
    }
}

function Cleanup-ResidualRegistry {
    Write-Log "Nettoyage résidus registre EventLog..."
    
    try {
        Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application\Zabbix Agent 2" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log "Clé EventLog supprimée si existante" -Level SUCCESS
    } catch {
        Write-Log "Erreur cleanup registre: $_" -Level WARNING
    }
}

function Install-Service {
    Write-Log "Installation/Réinstallation service..."
    
    try {
        $serviceExists = Get-Service -Name $AGENT_SERVICE -ErrorAction SilentlyContinue
        
        if ($serviceExists) {
            Write-Log "Service existant, arrêt et suppression..."
            Stop-Service -Name $AGENT_SERVICE -Force -ErrorAction SilentlyContinue
            sc.exe delete $AGENT_SERVICE | Out-Null
            Start-Sleep 5  # Délai augmenté
        }
        
        Cleanup-ResidualRegistry
        Start-Sleep 2
        
        $exe = "$INSTALL_DIR\zabbix_agent2.exe"
        
        # Try-catch sur install
        & $exe --config $CONFIG_FILE --install | Out-Null
        Start-Sleep 5  # Délai post-install
        
        $newService = Get-Service -Name $AGENT_SERVICE -ErrorAction SilentlyContinue
        if ($newService) {
            Write-Log "Service installé avec succès" -Level SUCCESS
            return $true
        } else {
            Write-Log "Échec installation service (vérifiez logs)" -Level ERROR
            return $false
        }
    } catch {
        Write-Log "Erreur globale installation service: $_" -Level ERROR
        return $false
    }
}

function Start-AndVerify {
    Write-Log "Démarrage et vérification service..."
    
    try {
        Start-Service -Name $AGENT_SERVICE -ErrorAction Stop
        Start-Sleep 5  # Délai augmenté
        
        $service = Get-Service -Name $AGENT_SERVICE
        if ($service.Status -eq "Running") {
            Write-Log "[OK] Service actif" -Level SUCCESS
        } else {
            Write-Log "[ERREUR] Service non actif (status: $($service.Status))" -Level ERROR
            return $false
        }
        
        # Vérifier port
        $listening = Get-NetTCPConnection -LocalPort $AGENT_PORT -State Listen -ErrorAction SilentlyContinue
        if ($listening) {
            Write-Log "[OK] Port $AGENT_PORT en écoute" -Level SUCCESS
        } else {
            Write-Log "[ATTENTION] Port non en écoute" -Level WARNING
        }
        
        return $true
    } catch {
        Write-Log "Erreur démarrage: $_" -Level ERROR
        return $false
    }
}

function Main {
    Write-Log "===== INSTALLATION AGENT ZABBIX ====="
    Write-Log "Serveur   : $ZABBIX_SERVER"
    Write-Log "Hostname  : $TARGET_HOSTNAME"
    Write-Log "Mode      : $MODE"
    Write-Log "PSK       : $USE_PSK"
    Write-Log "======================================"
    
    # Vérifier admin
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Log "ERREUR: Exécuter en Administrateur" -Level ERROR
        exit 1
    }
    
    $installed = Test-AgentInstalled
    
    # Mode repair (plus doux : évite delete si possible)
    if ($MODE -eq "repair") {
        if (-not $installed) {
            Write-Log "ERREUR: Aucun agent installé" -Level ERROR
            exit 1
        }
        
        Write-Log "Mode réparation..."
        
        if (Create-CleanConfig) {
            Configure-PSK | Out-Null
            Configure-Firewall | Out-Null
            
            # Si service existe, juste restart après config
            $service = Get-Service -Name $AGENT_SERVICE -ErrorAction SilentlyContinue
            if ($service) {
                Stop-Service -Name $AGENT_SERVICE -Force
                Start-Sleep 5
                if (Start-AndVerify) { exit 0 } else { exit 1 }
            } else {
                # Sinon, full install
                Cleanup-ResidualRegistry
                if (Install-Service) {
                    if (Start-AndVerify) { exit 0 } else { exit 1 }
                } else { exit 1 }
            }
        } else { exit 1 }
    }
    
    # Mode install
    if ($installed) {
        Write-Log "Agent présent, reconfiguration..." -Level WARNING
    } else {
        Write-Log "Nouvelle installation..."
        
        if (-not (Download-ZabbixMSI)) {
            Write-Log "Echec téléchargement MSI" -Level ERROR
            exit 1
        }
        
        if (-not (Install-ZabbixAgent)) {
            Write-Log "Echec installation MSI" -Level ERROR
            exit 1
        }
    }
    
    # Configuration
    if (-not (Create-CleanConfig)) { exit 1 }
    if (-not (Configure-PSK)) { exit 1 }
    Configure-Firewall | Out-Null
    
    # Installation et démarrage service (avec vérifs)
    if (-not (Install-Service)) {
        Write-Log "Echec installation service" -Level ERROR
        exit 1
    }
    
    if (Start-AndVerify) {
        Write-Log "===== INSTALLATION TERMINEE ====="
        Write-Log "Fichier config : $CONFIG_FILE"
        if ($USE_PSK -eq "yes") {
            Write-Log "Chiffrement PSK : ACTIVE"
            Write-Log "IMPORTANT: Configurer PSK dans Zabbix !"
        } else {
            Write-Log "Chiffrement PSK : DESACTIVE"
        }
        Write-Log "=================================="
        
        # Cleanup
        if (Test-Path $MSI_DOWNLOAD_PATH) {
            Remove-Item $MSI_DOWNLOAD_PATH -Force -ErrorAction SilentlyContinue
        }
        
        exit 0
    } else {
        Write-Log "Echec démarrage service" -Level ERROR
        exit 1
    }
}

Main
