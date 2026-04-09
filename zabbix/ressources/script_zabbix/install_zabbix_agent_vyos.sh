#!/bin/bash
################################################################################
# Script : install_zabbix_agent_vyos.sh
# Version : 1.0 - VYOS NATIVE CLI
# Compatible : VyOS 1.4+ (Sagitta)
# Description : Installation Zabbix Agent 2 via CLI VyOS native
# Documentation : https://docs.vyos.io/ + https://blog.vyos.io/vyos-project-december-2024-update
################################################################################

set -euo pipefail

# Variables d'environnement (fournies par orchestrateur)
ZABBIX_SERVER="${ZABBIX_SERVER:-10.20.20.12}"
HOSTNAME="${HOSTNAME:-$(hostname)}"
USE_PSK="${USE_PSK:-no}"
PSK_IDENTITY="${PSK_IDENTITY:-PSK:${HOSTNAME}}"
PSK_CONTENT="${PSK_CONTENT:-}"

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

detect_vyos() {
    log "Detection VyOS..."
    
    if [ ! -f /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper ]; then
        log "ERREUR: Ce n'est pas un systeme VyOS"
        exit 1
    fi
    
    # Version VyOS
    VYOS_VERSION=$(show version | grep "Version:" | awk '{print $2}')
    log "VyOS detecte: $VYOS_VERSION"
    
    # Verifier version minimale 1.4
    MAJOR=$(echo "$VYOS_VERSION" | cut -d. -f1)
    MINOR=$(echo "$VYOS_VERSION" | cut -d. -f2 | cut -d- -f1)
    
    if [ "$MAJOR" -lt 1 ] || { [ "$MAJOR" -eq 1 ] && [ "$MINOR" -lt 4 ]; }; then
        log "ERREUR: VyOS 1.4+ requis (version actuelle: $VYOS_VERSION)"
        exit 1
    fi
    
    log "Version compatible [OK]"
    return 0
}

check_existing_agent() {
    log "Verification agent existant..."
    
    # Verifier si service monitoring zabbix-agent configure
    if /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper show service monitoring zabbix-agent &>/dev/null; then
        log "Agent deja configure"
        return 0
    else
        log "Aucune configuration detectee"
        return 1
    fi
}

configure_zabbix_agent() {
    log "Configuration Zabbix Agent via CLI VyOS..."
    
    # Wrapper pour executer commandes VyOS
    VCMD="/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper"
    
    # Entrer en mode configuration
    log "Mode configuration..."
    
    # Configuration de base
    log "  - Serveur Zabbix: $ZABBIX_SERVER"
    $VCMD begin
    $VCMD set service monitoring zabbix-agent server "$ZABBIX_SERVER"
    $VCMD set service monitoring zabbix-agent server-active "$ZABBIX_SERVER" port 10051
    
    # Hostname
    log "  - Hostname: $HOSTNAME"
    $VCMD set service monitoring zabbix-agent host-name "$HOSTNAME"
    
    # Logs
    $VCMD set service monitoring zabbix-agent log debug-level warning
    $VCMD set service monitoring zabbix-agent log size 10
    
    # Directory pour fichiers temporaires
    $VCMD set service monitoring zabbix-agent directory /config/zabbix/
    
    # Configuration PSK si active
    if [ "$USE_PSK" = "yes" ]; then
        if [ -z "$PSK_CONTENT" ]; then
            log "ERREUR: PSK_CONTENT vide"
            $VCMD end
            exit 1
        fi
        
        log "  - Configuration PSK..."
        $VCMD set service monitoring zabbix-agent authentication mode pre-shared-secret
        $VCMD set service monitoring zabbix-agent psk id "$PSK_IDENTITY"
        $VCMD set service monitoring zabbix-agent psk secret "$PSK_CONTENT"
        log "    Identity: $PSK_IDENTITY"
        log "    Secret: ${PSK_CONTENT:0:16}...${PSK_CONTENT: -16}"
    else
        log "  - PSK desactive (connexion non chiffree)"
    fi
    
    # Commit et save
    log "Application configuration..."
    if ! $VCMD commit; then
        log "ERREUR: Echec commit configuration"
        $VCMD end
        exit 1
    fi
    
    log "Sauvegarde configuration..."
    if ! $VCMD save; then
        log "ERREUR: Echec sauvegarde configuration"
        $VCMD end
        exit 1
    fi
    
    $VCMD end
    
    log "Configuration appliquee [OK]"
    return 0
}

verify_agent() {
    log "Verification agent..."
    
    # Attendre demarrage
    sleep 5
    
    # Verifier processus
    if pgrep -x "zabbix_agent2" >/dev/null; then
        log "[OK] Processus zabbix_agent2 actif"
    else
        log "[ATTENTION] Processus non detecte"
        log "Verifier: show service monitoring zabbix-agent"
        return 1
    fi
    
    # Verifier port
    if ss -tlnp 2>/dev/null | grep -q ":10050"; then
        log "[OK] Port 10050 en ecoute"
    else
        log "[ATTENTION] Port 10050 non en ecoute"
        return 1
    fi
    
    # Afficher config actuelle
    log "Configuration actuelle:"
    /opt/vyatta/sbin/vyatta-cfg-cmd-wrapper show service monitoring zabbix-agent
    
    return 0
}

main() {
    log "===== INSTALLATION ZABBIX AGENT VYOS ====="
    log "Serveur   : $ZABBIX_SERVER"
    log "Hostname  : $HOSTNAME"
    log "PSK       : $USE_PSK"
    log "=========================================="
    
    # Verifier VyOS
    detect_vyos
    
    # Verifier agent existant
    if check_existing_agent; then
        log "Reconfiguration agent existant..."
    else
        log "Nouvelle installation..."
    fi
    
    # Configuration
    configure_zabbix_agent
    
    # Verification
    if verify_agent; then
        log "===== INSTALLATION TERMINEE ====="
        log "Agent VyOS configure avec succes"
        if [ "$USE_PSK" = "yes" ]; then
            log "Chiffrement PSK : ACTIVE"
            log "IMPORTANT: Configurer PSK dans Zabbix UI !"
        else
            log "Chiffrement PSK : DESACTIVE"
        fi
        log "=================================="
        exit 0
    else
        log "ERREUR: Verification echouee"
        exit 1
    fi
}

main "$@"
