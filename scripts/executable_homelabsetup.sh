#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCKER_DIR="$SCRIPT_DIR"

print_header() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}          ${BOLD}Simple Homelab Setup${NC}                            ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[$1/$2]${NC} $3"
}

main_menu() {
    print_header
    echo -e "${BOLD}Select an option:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} Install & Setup Services"
    echo -e "  ${GREEN}2)${NC} Stop Services"
    echo -e "  ${GREEN}3)${NC} View Service Status"
    echo -e "  ${GREEN}4)${NC} Uninstall (remove everything)"
    echo -e "  ${GREEN}5)${NC} Exit"
    echo ""
    read -p "Enter choice: " CHOICE
    
    case $CHOICE in
        1) install_and_setup ;;
        2) stop_services ;;
        3) view_status ;;
        4) uninstall ;;
        5) exit 0 ;;
        *) echo "Invalid option"; sleep 1; main_menu ;;
    esac
}

install_docker() {
    print_step 1 4 "Installing Docker..."
    
    if command -v docker &> /dev/null; then
        print_status "Docker already installed"
        if ! systemctl is-active --quiet docker; then
            print_status "Starting Docker..."
            systemctl start docker
        fi
        return
    fi
    
    apt update -qq
    apt install -y -qq ca-certificates curl gnupg lsb-release > /dev/null 2>&1
    
    CODENAME=$(lsb_release -cs 2>/dev/null || echo "jammy")
    case "$CODENAME" in
        focal|jammy|noble|trusty|bionic) ;;
        *) CODENAME="jammy" ;;
    esac
    
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null || {
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - 2>/dev/null
    }
    
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable" > /etc/apt/sources.list.d/docker.list
    
    apt update -qq
    apt install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1
    
    systemctl enable docker
    systemctl start docker
    print_status "Docker installed successfully"
}

select_services() {
    print_step 2 4 "Selecting services..."
    echo ""
    
    echo -e "${BOLD}Core Services:${NC}"
    echo ""
    
    toggle_service "Portainer" "Docker GUI - manage containers via web" "INSTALL_PORTAINER"
    toggle_service "AdGuard Home" "Ad blocker & DNS (better than Pi-hole on WSL)" "INSTALL_ADGUARD"
    
    echo -e "\n${BOLD}Media & Downloads:${NC}"
    echo ""
    
    toggle_service "Jellyfin" "Media server for movies, TV, music" "INSTALL_JELLYFIN"
    toggle_service "qBittorrent" "Download client for torrents" "INSTALL_QBITTORRENT"
    toggle_service "*arr Stack" "Sonarr/Radarr/Lidarr/Prowlarr automation" "INSTALL_ARR"
    
    echo -e "\n${BOLD}Cloud & Storage:${NC}"
    echo ""
    
    toggle_service "Nextcloud" "Self-hosted cloud storage" "INSTALL_NEXTCLOUD"
    
    echo -e "\n${BOLD}Networking & VPN:${NC}"
    echo ""
    
    toggle_service "Tailscale" "Mesh VPN for remote access" "INSTALL_TAILSCALE"
    toggle_service "Nginx Proxy Manager" "Reverse proxy with GUI" "INSTALL_NPM"
    
    echo -e "\n${BOLD}Monitoring:${NC}"
    echo ""
    
    toggle_service "Uptime Kuma" "Self-hosted monitoring dashboard" "INSTALL_UPTIME"
}

toggle_service() {
    local name="$1"
    local desc="$2"
    local varname="$3"
    read -p "  Install $name? [y/N]: " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        eval "$varname=1"
    else
        eval "$varname=0"
    fi
}

get_config() {
    print_step 3 4 "Configuration"
    echo ""
    
    read -p "  Timezone (e.g. America/New_York): " TIMEZONE
    TIMEZONE=${TIMEZONE:-America/New_York}
    
    if [ "$INSTALL_ADGUARD" = "1" ]; then
        read -p "  AdGuard admin password: " ADGUARD_PASSWORD
        ADGUARD_PASSWORD=${ADGUARD_PASSWORD:-adminadmin}
    fi
    
    if [ "$INSTALL_TAILSCALE" = "1" ]; then
        echo ""
        print_warning "Get your auth key from: https://login.tailscale.com/admin/settings/keys"
        read -p "  Tailscale Auth Key: " TAILSCALE_KEY
    fi
}

setup_services() {
    print_step 4 4 "Setting up services..."
    echo ""
    
    mkdir -p "$DOCKER_DIR"
    mkdir -p "$DOCKER_DIR/downloads"
    
    cat > "$DOCKER_DIR/docker-compose.yml" << 'EOF'
services:
EOF

    if [ "$INSTALL_PORTAINER" = "1" ]; then
        print_status "Adding Portainer..."
        cat >> "$DOCKER_DIR/docker-compose.yml" << 'EOF'
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    ports:
      - "9443:9443"
      - "9000:9000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./portainer/data:/data
    restart: unless-stopped
EOF
    fi

    if [ "$INSTALL_ADGUARD" = "1" ]; then
        print_status "Adding AdGuard Home..."
        cat >> "$DOCKER_DIR/docker-compose.yml" << EOF
  adguard:
    image: adguard/adguardhome:latest
    container_name: adguard
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "3080:80/tcp"
      - "3443:443/tcp"
      - "853:853/tcp"
    volumes:
      - ./adguard/work:/opt/adguardhome/work
      - ./adguard/conf:/opt/adguardhome/conf
    restart: unless-stopped
EOF
    fi

    if [ "$INSTALL_JELLYFIN" = "1" ]; then
        print_status "Adding Jellyfin..."
        mkdir -p "$DOCKER_DIR/media/{movies,tv,music}"
        cat >> "$DOCKER_DIR/docker-compose.yml" << EOF
  jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    ports:
      - "8096:8096"
      - "8920:8920"
    environment:
      TZ: $TIMEZONE
    volumes:
      - ./jellyfin/config:/config
      - ./jellyfin/cache:/cache
      - ./media/movies:/media/movies
      - ./media/tv:/media/tv
      - ./media/music:/media/music
    restart: unless-stopped
EOF
    fi

    if [ "$INSTALL_QBITTORRENT" = "1" ]; then
        print_status "Adding qBittorrent..."
        cat >> "$DOCKER_DIR/docker-compose.yml" << EOF
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      PUID: 1000
      PGID: 1000
      TZ: $TIMEZONE
      WEBUI_PORT: 8081
    volumes:
      - ./qbittorrent/config:/config
      - ./downloads:/downloads
    ports:
      - "6881:6881"
      - "6881:6881/udp"
      - "8081:8081"
    restart: unless-stopped
EOF
    fi

    if [ "$INSTALL_ARR" = "1" ]; then
        print_status "Adding *arr Stack..."
        mkdir -p "$DOCKER_DIR"/{sonarr,radarr,lidarr,prowlarr}/config
        cat >> "$DOCKER_DIR/docker-compose.yml" << EOF
  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    environment:
      PUID: 1000
      PGID: 1000
      TZ: $TIMEZONE
    volumes:
      - ./prowlarr/config:/config
    ports:
      - "9696:9696"
    restart: unless-stopped

  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    environment:
      PUID: 1000
      PGID: 1000
      TZ: $TIMEZONE
    volumes:
      - ./sonarr/config:/config
      - ./media/tv:/tv
      - ./downloads:/downloads
    ports:
      - "8989:8989"
    restart: unless-stopped

  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    environment:
      PUID: 1000
      PGID: 1000
      TZ: $TIMEZONE
    volumes:
      - ./radarr/config:/config
      - ./media/movies:/movies
      - ./downloads:/downloads
    ports:
      - "7878:7878"
    restart: unless-stopped

  lidarr:
    image: lscr.io/linuxserver/lidarr:latest
    container_name: lidarr
    environment:
      PUID: 1000
      PGID: 1000
      TZ: $TIMEZONE
    volumes:
      - ./lidarr/config:/config
      - ./media/music:/music
      - ./downloads:/downloads
    ports:
      - "8686:8686"
    restart: unless-stopped
EOF
    fi

    if [ "$INSTALL_NEXTCLOUD" = "1" ]; then
        print_status "Adding Nextcloud..."
        mkdir -p "$DOCKER_DIR/nextcloud/{config,data,apps}"
        cat >> "$DOCKER_DIR/docker-compose.yml" << EOF
  nextcloud:
    image: nextcloud:latest
    container_name: nextcloud
    ports:
      - "8282:80"
    environment:
      TZ: $TIMEZONE
    volumes:
      - ./nextcloud/config:/var/www/html/config
      - ./nextcloud/data:/var/www/html/data
      - ./nextcloud/apps:/var/www/html/apps
    restart: unless-stopped
EOF
    fi

    if [ "$INSTALL_TAILSCALE" = "1" ]; then
        print_status "Adding Tailscale..."
        cat >> "$DOCKER_DIR/docker-compose.yml" << EOF
  tailscale:
    image: tailscale/tailscale:latest
    container_name: tailscale
    hostname: homelab
    environment:
      - TS_AUTH_KEY=${TAILSCALE_KEY}
      - TS_STATE_DIR=/var/lib/tailscale
      - TS_USERSPACE=false
    volumes:
      - /dev/net/tun:/dev/net/tun
      - ./tailscale:/var/lib/tailscale
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    restart: unless-stopped
EOF
    fi

    if [ "$INSTALL_NPM" = "1" ]; then
        print_status "Adding Nginx Proxy Manager..."
        mkdir -p "$DOCKER_DIR/npm/{data,letsencrypt}"
        cat >> "$DOCKER_DIR/docker-compose.yml" << EOF
  npm:
    image: jc21/nginx-proxy-manager:latest
    container_name: npm
    ports:
      - "80:80"
      - "443:443"
      - "8181:81"
    environment:
      DB_SQLITE_FILE: /data/database.sqlite
    volumes:
      - ./npm/data:/data
      - ./npm/letsencrypt:/etc/letsencrypt
    restart: unless-stopped
EOF
    fi

    if [ "$INSTALL_UPTIME" = "1" ]; then
        print_status "Adding Uptime Kuma..."
        mkdir -p "$DOCKER_DIR/uptime/data"
        cat >> "$DOCKER_DIR/docker-compose.yml" << EOF
  uptime:
    image: louislam/uptime-kuma:latest
    container_name: uptime
    ports:
      - "3001:3001"
    volumes:
      - ./uptime/data:/app/data
    restart: unless-stopped
EOF
    fi

    print_status "Created docker-compose.yml"
}

start_services() {
    if [ ! -f "$DOCKER_DIR/docker-compose.yml" ]; then
        print_error "No docker-compose.yml found. Run option 1 first."
        return
    fi
    
    cd "$DOCKER_DIR"
    echo ""
    print_status "Starting services..."
    docker compose up -d
    
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${BOLD}Setup Complete!${NC}                        ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Access your services at:${NC}"
    echo ""
    
    [ "$INSTALL_PORTAINER" = "1" ] && echo -e "  ${GREEN}Portainer:${NC}    https://$(hostname -I | awk '{print $1}'):9443"
    [ "$INSTALL_ADGUARD" = "1" ] && echo -e "  ${GREEN}AdGuard:${NC}      http://$(hostname -I | awk '{print $1}'):3080"
    [ "$INSTALL_JELLYFIN" = "1" ] && echo -e "  ${GREEN}Jellyfin:${NC}    http://$(hostname -I | awk '{print $1}'):8096"
    [ "$INSTALL_QBITTORRENT" = "1" ] && echo -e "  ${GREEN}qBittorrent:${NC} http://$(hostname -I | awk '{print $1}'):8081"
    [ "$INSTALL_ARR" = "1" ] && echo -e "  ${GREEN}Prowlarr:${NC}    http://$(hostname -I | awk '{print $1}'):9696"
    [ "$INSTALL_ARR" = "1" ] && echo -e "  ${GREEN}Sonarr:${NC}      http://$(hostname -I | awk '{print $1}'):8989"
    [ "$INSTALL_ARR" = "1" ] && echo -e "  ${GREEN}Radarr:${NC}      http://$(hostname -I | awk '{print $1}'):7878"
    [ "$INSTALL_ARR" = "1" ] && echo -e "  ${GREEN}Lidarr:${NC}      http://$(hostname -I | awk '{print $1}'):8686"
    [ "$INSTALL_NEXTCLOUD" = "1" ] && echo -e "  ${GREEN}Nextcloud:${NC}   http://$(hostname -I | awk '{print $1}'):8282"
    [ "$INSTALL_NPM" = "1" ] && echo -e "  ${GREEN}Nginx PM:${NC}     http://$(hostname -I | awk '{print $1}'):8181"
    [ "$INSTALL_UPTIME" = "1" ] && echo -e "  ${GREEN}Uptime Kuma:${NC} http://$(hostname -I | awk '{print $1}'):3001"
    [ "$INSTALL_TAILSCALE" = "1" ] && echo -e "  ${GREEN}Tailscale:${NC}   Use \`docker logs tailscale\` to see status"
    echo ""
    echo -e "Check status: ${CYAN}docker ps${NC}"
    echo ""
}

view_status() {
    echo ""
    echo -e "${BOLD}Service Status:${NC}"
    echo ""
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || print_error "Docker not running"
    echo ""
}

stop_services() {
    echo ""
    echo "Stopping services..."
    if [ -d "$DOCKER_DIR" ]; then
        cd "$DOCKER_DIR"
        docker compose down 2>/dev/null || echo "  No services running"
    else
        echo "  No docker directory found"
    fi
    print_status "Done"
}

uninstall() {
    print_header
    echo -e "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC}                      ${BOLD}UNINSTALL${NC}                         ${RED}║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "This will:"
    echo "  1. Stop and remove all containers"
    echo "  2. Remove all data (volumes)"
    echo "  3. Delete docker-compose.yml and configs"
    echo ""
    read -p "Type 'yes' to confirm: " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        print_status "Cancelled"
        exit 0
    fi
    
    echo ""
    print_status "Removing containers and data..."
    if [ -d "$DOCKER_DIR" ]; then
        cd "$DOCKER_DIR"
        docker compose down -v 2>/dev/null || true
        cd ..
        rm -rf "$DOCKER_DIR"
        print_status "Removed docker folder"
    fi
    
    echo ""
    read -p "Uninstall Docker? (recommended to keep) [y/N]: " UNINSTALL_DOCKER
    if [ "$UNINSTALL_DOCKER" = "y" ] || [ "$UNINSTALL_DOCKER" = "Y" ]; then
        systemctl stop docker
        apt remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
        rm -rf /var/lib/docker /etc/apt/sources.list.d/docker.list /etc/apt/keyrings/docker.gpg 2>/dev/null || true
        print_status "Docker uninstalled"
    fi
    
    echo ""
    echo -e "${GREEN}Uninstall complete!${NC}"
}

install_and_setup() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Run with: sudo bash setup.sh${NC}"
        exit 1
    fi
    
    print_header
    install_docker
    select_services
    get_config
    setup_services
    start_services
}

main_menu
