#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[m'
BOLD='\033[1m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCKER_DIR="$SCRIPT_DIR"

# ----------------------------------------------------------------------
#  Helper functions
# ----------------------------------------------------------------------
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

# ----------------------------------------------------------------------
#  Ensure curl is installed (needed for Docker install script)
# ----------------------------------------------------------------------
ensure_curl() {
    if command -v curl &>/dev/null; then
        return 0
    fi
    print_warning "curl not found. Attempting to install curl..."
    # Detect package manager and install curl
    if command -v apt &>/dev/null; then
        apt update -qq && apt install -y -qq curl
    elif command -v pacman &>/dev/null; then
        pacman -Sy --noconfirm curl
    elif command -v zypper &>/dev/null; then
        zypper install -y curl
    elif command -v dnf &>/dev/null; then
        dnf install -y curl
    else
        print_error "Could not install curl. Please install it manually and re-run this script."
        exit 1
    fi
    print_status "curl installed."
}

# ----------------------------------------------------------------------
#  Docker installation (universal)
# ----------------------------------------------------------------------
install_docker() {
    print_step 1 4 "Installing Docker..."

    if command -v docker &> /dev/null; then
        print_status "Docker already installed"
        if ! systemctl is-active --quiet docker; then
            print_status "Starting Docker..."
            systemctl start docker
        fi
        # Ensure compose plugin is available
        if ! docker compose version &>/dev/null; then
            print_warning "docker compose plugin missing. Reinstalling Docker..."
            # Continue with fresh install
        else
            return
        fi
    fi

    ensure_curl

    print_status "Downloading and running Docker installation script..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh
    rm -f /tmp/get-docker.sh

    # Start Docker service
    systemctl enable docker
    systemctl start docker

    # Add current user to docker group (if not root)
    if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
        print_status "Adding user $SUDO_USER to docker group..."
        usermod -aG docker "$SUDO_USER"
        print_warning "You may need to log out and back in for group changes to take effect."
    fi

    print_status "Docker installed successfully"
}

# ----------------------------------------------------------------------
#  Interactive service selection
# ----------------------------------------------------------------------
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

select_services() {
    print_step 2 4 "Selecting services..."
    echo ""

    echo -e "${BOLD}Core Services:${NC}"
    echo ""
    toggle_service "AdGuard Home" "Ad blocker & DNS (better than Pi-hole on WSL)" "INSTALL_ADGUARD"

    echo -e "\n${BOLD}Media & Downloads:${NC}"
    echo ""
    toggle_service "Jellyfin" "Media server for movies, TV, music" "INSTALL_JELLYFIN"
    toggle_service "qBittorrent" "Download client for torrents" "INSTALL_QBITTORRENT"
    toggle_service "*arr Stack" "Sonarr/Radarr/Lidarr/Prowlarr automation" "INSTALL_ARR"

    echo -e "\n${BOLD}Cloud & Storage:${NC}"
    echo ""
    toggle_service "Nextcloud" "Self-hosted cloud storage" "INSTALL_NEXTCLOUD"

    echo -e "\n${BOLD}Networking & Reverse Proxy:${NC}"
    echo ""
    toggle_service "Nginx Proxy Manager" "Reverse proxy with GUI" "INSTALL_NPM"

    echo -e "\n${BOLD}Monitoring:${NC}"
    echo ""
    toggle_service "Uptime Kuma" "Self-hosted monitoring dashboard" "INSTALL_UPTIME"

    # Tailscale container removed – use host Tailscale instead
}

# ----------------------------------------------------------------------
#  Configuration
# ----------------------------------------------------------------------
get_config() {
    print_step 3 4 "Configuration"
    echo ""

    read -p "  Timezone (e.g. America/New_York): " TIMEZONE
    TIMEZONE=${TIMEZONE:-America/New_York}

    # AdGuard password not needed – set on first web login
}

# ----------------------------------------------------------------------
#  Choose IP address for service links
# ----------------------------------------------------------------------
choose_ip() {
    local ips=($(ip -4 -o addr show | awk '{print $4}' | cut -d/ -f1 | grep -v '^127\.'))
    if [ ${#ips[@]} -eq 0 ]; then
        print_error "No non‑loopback IP found. Using hostname -I fallback."
        IP=$(hostname -I | awk '{print $1}')
    elif [ ${#ips[@]} -eq 1 ]; then
        IP="${ips[0]}"
    else
        echo ""
        echo -e "${BOLD}Detected IP addresses:${NC}"
        for i in "${!ips[@]}"; do
            echo "  $((i+1))) ${ips[$i]}"
        done
        read -p "  Which IP should be used for service links? [1]: " choice
        choice=${choice:-1}
        if [[ $choice -ge 1 && $choice -le ${#ips[@]} ]]; then
            IP="${ips[$((choice-1))]}"
        else
            IP="${ips[0]}"
            print_warning "Invalid choice, using $IP"
        fi
    fi
    print_status "Using IP: $IP"
}

# ----------------------------------------------------------------------
#  Port conflict check (uses ss)
# ----------------------------------------------------------------------
check_port() {
    local port=$1
    if command -v ss &>/dev/null && ss -tulpn | grep -q ":$port "; then
        print_warning "Port $port is already in use. The container may fail to start."
        return 1
    fi
    return 0
}

# ----------------------------------------------------------------------
#  Generate docker-compose.yml
# ----------------------------------------------------------------------
setup_services() {
    print_step 4 4 "Setting up services..."
    echo ""

    mkdir -p "$DOCKER_DIR/downloads"
    mkdir -p "$DOCKER_DIR/media/movies" "$DOCKER_DIR/media/tv" "$DOCKER_DIR/media/music"

    # Check for existing compose file
    if [ -f "$DOCKER_DIR/docker-compose.yml" ]; then
        read -p "  docker-compose.yml already exists. Overwrite? [y/N]: " overwrite
        if [[ ! $overwrite =~ ^[Yy]$ ]]; then
            print_warning "Keeping existing file. New services will NOT be added."
            return
        fi
    fi

    cat > "$DOCKER_DIR/docker-compose.yml" << 'EOF'
services:
EOF

    # AdGuard Home
    if [ "$INSTALL_ADGUARD" = "1" ]; then
        print_status "Adding AdGuard Home..."
        check_port 53 || true
        check_port 3080 || true
        check_port 3443 || true
        check_port 853 || true
        cat >> "$DOCKER_DIR/docker-compose.yml" << 'EOF'
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

    # Jellyfin
    if [ "$INSTALL_JELLYFIN" = "1" ]; then
        print_status "Adding Jellyfin..."
        check_port 8096 || true
        check_port 8920 || true
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

    # qBittorrent
    if [ "$INSTALL_QBITTORRENT" = "1" ]; then
        print_status "Adding qBittorrent..."
        check_port 8081 || true
        check_port 6881 || true
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

    # *arr stack
    if [ "$INSTALL_ARR" = "1" ]; then
        print_status "Adding *arr Stack..."
        mkdir -p "$DOCKER_DIR"/{sonarr,radarr,lidarr,prowlarr}/config
        check_port 9696 || true
        check_port 8989 || true
        check_port 7878 || true
        check_port 8686 || true
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

    # Nextcloud
    if [ "$INSTALL_NEXTCLOUD" = "1" ]; then
        print_status "Adding Nextcloud..."
        mkdir -p "$DOCKER_DIR/nextcloud/config" "$DOCKER_DIR/nextcloud/data" "$DOCKER_DIR/nextcloud/apps"
        check_port 8282 || true
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

    # Nginx Proxy Manager
    if [ "$INSTALL_NPM" = "1" ]; then
        print_status "Adding Nginx Proxy Manager..."
        mkdir -p "$DOCKER_DIR/npm/data" "$DOCKER_DIR/npm/letsencrypt"
        check_port 80 || true
        check_port 443 || true
        check_port 8181 || true
        cat >> "$DOCKER_DIR/docker-compose.yml" << 'EOF'
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

    # Uptime Kuma
    if [ "$INSTALL_UPTIME" = "1" ]; then
        print_status "Adding Uptime Kuma..."
        mkdir -p "$DOCKER_DIR/uptime/data"
        check_port 3001 || true
        cat >> "$DOCKER_DIR/docker-compose.yml" << 'EOF'
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

# ----------------------------------------------------------------------
#  Start services and print info
# ----------------------------------------------------------------------
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

    [ "$INSTALL_ADGUARD" = "1" ] && echo -e "  ${GREEN}AdGuard:${NC}      http://$IP:3080"
    [ "$INSTALL_JELLYFIN" = "1" ] && echo -e "  ${GREEN}Jellyfin:${NC}    http://$IP:8096"
    [ "$INSTALL_QBITTORRENT" = "1" ] && echo -e "  ${GREEN}qBittorrent:${NC} http://$IP:8081"
    [ "$INSTALL_ARR" = "1" ] && echo -e "  ${GREEN}Prowlarr:${NC}    http://$IP:9696"
    [ "$INSTALL_ARR" = "1" ] && echo -e "  ${GREEN}Sonarr:${NC}      http://$IP:8989"
    [ "$INSTALL_ARR" = "1" ] && echo -e "  ${GREEN}Radarr:${NC}      http://$IP:7878"
    [ "$INSTALL_ARR" = "1" ] && echo -e "  ${GREEN}Lidarr:${NC}      http://$IP:8686"
    [ "$INSTALL_NEXTCLOUD" = "1" ] && echo -e "  ${GREEN}Nextcloud:${NC}   http://$IP:8282"
    [ "$INSTALL_NPM" = "1" ] && echo -e "  ${GREEN}Nginx PM:${NC}     http://$IP:8181"
    [ "$INSTALL_UPTIME" = "1" ] && echo -e "  ${GREEN}Uptime Kuma:${NC} http://$IP:3001"

    echo ""
    echo -e "Check status: ${CYAN}docker ps${NC}"
    echo ""
}

# ----------------------------------------------------------------------
#  Status and management functions
# ----------------------------------------------------------------------
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
    echo "  4. Optionally uninstall Docker itself"
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
        print_status "Removed homelab directory"
    fi

    echo ""
    read -p "Uninstall Docker as well? [y/N]: " REMOVE_DOCKER
    if [[ $REMOVE_DOCKER =~ ^[Yy]$ ]]; then
        print_status "Removing Docker packages..."

        # Detect package manager and remove Docker packages
        if command -v apt &>/dev/null; then
            apt remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
            apt autoremove -y
            rm -rf /etc/apt/sources.list.d/docker.list /etc/apt/keyrings/docker.gpg
        elif command -v pacman &>/dev/null; then
            pacman -Rns --noconfirm docker docker-compose 2>/dev/null || true
        elif command -v zypper &>/dev/null; then
            zypper remove -y docker docker-compose 2>/dev/null || true
        elif command -v dnf &>/dev/null; then
            dnf remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 2>/dev/null || true
        else
            print_warning "Unsupported package manager. Please remove Docker manually."
        fi

        # Optionally remove Docker data directory
        read -p "Remove Docker data directory (/var/lib/docker)? This will delete all images, containers, and volumes. [y/N]: " REMOVE_DATA
        if [[ $REMOVE_DATA =~ ^[Yy]$ ]]; then
            rm -rf /var/lib/docker
            print_status "Removed /var/lib/docker"
        fi

        print_status "Docker uninstalled"
    fi

    echo ""
    echo -e "${GREEN}Uninstall complete!${NC}"
}

# ----------------------------------------------------------------------
#  Main menu
# ----------------------------------------------------------------------
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

install_and_setup() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Please run with: sudo bash setup.sh${NC}"
        exit 1
    fi

    print_header
    install_docker
    select_services
    get_config
    choose_ip
    setup_services
    start_services
}

main_menu0
