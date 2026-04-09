#!/bin/bash
################################################################################
# Script : install_zabbix_agent_debian.sh
# Version : 5.0 - PRODUCTION FINALE
# Configuration : Serveur/Proxy Zabbix dynamique (selon reseau)
# PSK : Gestion manuelle (fichiers crees par administrateur)
################################################################################

set -euo pipefail

ZABBIX_VERSION="${ZABBIX_VERSION:-7.4}"
ZABBIX_SERVER="${ZABBIX_SERVER:-10.20.20.12}"
HOSTNAME="${HOSTNAME:-$(hostname)}"
MODE="${MODE:-install}"
AGENT_TYPE="${AGENT_TYPE:-agent2}"
USE_PSK="${USE_PSK:-no}"
PSK_FILE="${PSK_FILE:-}"
PSK_IDENTITY="${PSK_IDENTITY:-PSK:${HOSTNAME}}"

if [ "$AGENT_TYPE" == "agent2" ]; then
    AGENT_PACKAGE="zabbix-agent2"
    AGENT_SERVICE="zabbix-agent2"
    AGENT_CONF="/etc/zabbix/zabbix_agent2.conf"
    AGENT_PORT="10050"
else
    AGENT_PACKAGE="zabbix-agent"
    AGENT_SERVICE="zabbix-agent"
    AGENT_CONF="/etc/zabbix/zabbix_agentd.conf"
    AGENT_PORT="10050"
fi

BACKUP_DIR="/root/zabbix_backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"; }

detect_distro() {
    [ ! -f /etc/os-release ] && { log "ERREUR: /etc/os-release non trouve"; exit 1; }
    . /etc/os-release
    DISTRO_ID="$ID"
    DISTRO_VERSION="$VERSION_CODENAME"
    log "Distribution: $DISTRO_ID $DISTRO_VERSION"
}

check_existing_agent() {
    log "Verification installation existante..."
    if dpkg -l | grep -qE "zabbix-agent2?"; then
        EXISTING_AGENT=true
        EXISTING_VERSION=$(dpkg -l | grep -E "zabbix-agent2?" | awk '{print $3}' | head -n1)
        log "Agent deja installe: $EXISTING_VERSION"
    else
            EXISTING_AGENT=false
            log "Aucun agent detecte"    
    fi
        return 0  
}

get_zabbix_repo_url() {
    local major_version="${ZABBIX_VERSION%.*}"
    case "$major_version" in
        7.0|7.2|7.4) REPO_VERSION="7.0" ;;
        *) REPO_VERSION="7.0" ;;
    esac
    
    local base_url="https://repo.zabbix.com/zabbix/${REPO_VERSION}"
    
    if [ "$DISTRO_ID" == "debian" ]; then
        case "$DISTRO_VERSION" in
            bullseye) debian_ver="11" ;;
            bookworm) debian_ver="12" ;;
            *) debian_ver="12" ;;
        esac
        REPO_URL="${base_url}/debian/pool/main/z/zabbix-release/zabbix-release_${REPO_VERSION}-2+debian${debian_ver}_all.deb"
    else
        case "$DISTRO_VERSION" in
            focal) ubuntu_ver="20.04" ;;
            jammy) ubuntu_ver="22.04" ;;
            noble) ubuntu_ver="24.04" ;;
            *) ubuntu_ver="22.04" ;;
        esac
        REPO_URL="${base_url}/ubuntu/pool/main/z/zabbix-release/zabbix-release_${REPO_VERSION}-2+ubuntu${ubuntu_ver}_all.deb"
    fi
    
    log "URL depot: $REPO_URL"
}

add_zabbix_repo() {
    log "Ajout depot Zabbix $ZABBIX_VERSION..."
    get_zabbix_repo_url
    
    local temp_deb="/tmp/zabbix-release.deb"
    wget -q -O "$temp_deb" "$REPO_URL" || { log "ERREUR: Telechargement echoue"; exit 1; }
    dpkg -i "$temp_deb" || { log "ERREUR: Installation zabbix-release echouee"; exit 1; }
    rm -f "$temp_deb"
    apt-get update -qq
    log "Depot ajoute"
}

install_agent() {
    log "Installation $AGENT_PACKAGE..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$AGENT_PACKAGE"
    systemctl enable "$AGENT_SERVICE" &>/dev/null || true
    log "Agent installe"
}

backup_config() {
    if [ -f "$AGENT_CONF" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$AGENT_CONF" "${BACKUP_DIR}/$(basename $AGENT_CONF).backup_${TIMESTAMP}"
        log "Config sauvegardee"
    fi
}

configure_agent() {
    log "Configuration agent..."
    backup_config
    
    sed -i "s|^Server=.*|Server=${ZABBIX_SERVER}|" "$AGENT_CONF"
    sed -i "s|^ServerActive=.*|ServerActive=${ZABBIX_SERVER}|" "$AGENT_CONF"
    sed -i "s|^Hostname=.*|Hostname=${HOSTNAME}|" "$AGENT_CONF"
    sed -i "s|^# LogFileSize=.*|LogFileSize=10|" "$AGENT_CONF"
    
    log "Configuration appliquee"
    log "  Server       : $ZABBIX_SERVER"
    log "  ServerActive : $ZABBIX_SERVER"
    log "  Hostname     : $HOSTNAME"
}

configure_psk() {
    if [ "$USE_PSK" != "yes" ]; then
        log "PSK desactive - Installation sans chiffrement"
        return 0
    fi
    
    if [ -z "$PSK_FILE" ] || [ ! -f "$PSK_FILE" ]; then
        log "ERREUR: Fichier PSK manquant ($PSK_FILE)"
        log "Installation sans chiffrement"
        return 1
    fi
    
    log "Configuration PSK..."
    
    local target_psk="/etc/zabbix/zabbix_agentd.psk"
    cp "$PSK_FILE" "$target_psk"
    chmod 600 "$target_psk"
    chown zabbix:zabbix "$target_psk" 2>/dev/null || true
    
    sed -i "s|^# TLSConnect=.*|TLSConnect=psk|" "$AGENT_CONF"
    sed -i "s|^# TLSAccept=.*|TLSAccept=psk|" "$AGENT_CONF"
    sed -i "s|^# TLSPSKIdentity=.*|TLSPSKIdentity=${PSK_IDENTITY}|" "$AGENT_CONF"
    sed -i "s|^# TLSPSKFile=.*|TLSPSKFile=${target_psk}|" "$AGENT_CONF"
    
    log "PSK configure [OK]"
    log "  Identity: $PSK_IDENTITY"
    log "  Fichier: $target_psk"
    
    return 0
}

configure_firewall() {
    log "Configuration pare-feu..."
    
    if command -v ufw &>/dev/null && ufw status | grep -q "Status: active"; then
        ufw allow from "$ZABBIX_SERVER" to any port "$AGENT_PORT" proto tcp comment "Zabbix Agent" || true
        log "UFW: regle ajoutee"
    elif command -v iptables &>/dev/null; then
        iptables -I INPUT -p tcp -s "$ZABBIX_SERVER" --dport "$AGENT_PORT" -j ACCEPT || true
        iptables-save > /etc/iptables/rules.v4 2>/dev/null || true
        log "iptables: regle ajoutee"
    fi
}

start_and_verify() {
    log "Demarrage $AGENT_SERVICE..."
    systemctl restart "$AGENT_SERVICE"
    sleep 3
    
    if systemctl is-active --quiet "$AGENT_SERVICE"; then
        log "[OK] Service actif"
    else
        log "[ERREUR] Service non actif"
        journalctl -u "$AGENT_SERVICE" -n 20 --no-pager
        return 1
    fi
    
    if ss -tlnp | grep -q ":${AGENT_PORT}"; then
        log "[OK] Port $AGENT_PORT en ecoute"
    else
        log "[ATTENTION] Port non en ecoute"
    fi
    
    return 0
}

main() {
    log "===== INSTALLATION AGENT ZABBIX ====="
    log "Serveur   : $ZABBIX_SERVER"
    log "Hostname  : $HOSTNAME"
    log "Mode      : $MODE"
    log "PSK       : $USE_PSK"
    log "====================================="
    
    [ "$EUID" -ne 0 ] && { log "ERREUR: Executer en root"; exit 1; }
    
    detect_distro
    check_existing_agent
    
    if [ "$MODE" = "install" ] || [ "$MODE" = "repair" ]; then
        if [ "$EXISTING_AGENT" != "true" ]; then
            add_zabbix_repo
            install_agent
        else
            log "Agent existant -> reconfiguration"
        fi
        
        configure_agent
        configure_psk
        configure_firewall
        start_and_verify
    fi
    
    log "===== INSTALLATION TERMINEE ====="
    log "Fichier de config : $AGENT_CONF"
    if [ "$USE_PSK" = "yes" ]; then
        log "Chiffrement PSK   : ACTIVE"
        log "Configurer PSK cote serveur Zabbix !"
    else
        log "Chiffrement PSK   : DESACTIVE"
    fi
    log "=================================="
    
    exit 0
}

main "$@"
