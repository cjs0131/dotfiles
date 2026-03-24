#!/bin/bash

# ── Package tiers ────────────────────────────────────────────────────────────
CORE_PACKAGES=(
  "fish"
  "btop"
  "htop"
  "neovim"
  "fzf"
)

FULL_PACKAGES=(
  "${CORE_PACKAGES[@]}"
  "fastfetch"
  "ranger"
  "zellij"
  "yt-dlp"
  "lazygit"
)

GAMING_PACKAGES=(
  "${FULL_PACKAGES[@]}"
  "steam"
  "lutris"
  "gamemode"
  "mangohud"
)

# ── Package manager installers ───────────────────────────────────────────────
install_apt() {
  sudo apt update
  for pkg in "$@"; do
    sudo apt install -y "$pkg" 2>/dev/null && echo "✓ $pkg" || echo "✗ $pkg (not found in apt)"
  done
}
install_dnf() {
  for pkg in "$@"; do
    sudo dnf install -y "$pkg" && echo "✓ $pkg" || echo "✗ $pkg (not found in dnf)"
  done
}
install_pacman() {
  if command -v paru &>/dev/null; then
    paru -S --noconfirm "$@"
  else
    sudo pacman -S --noconfirm "$@"
  fi
}
install_zypper() {
  for pkg in "$@"; do
    sudo zypper install -y --no-recommends "$pkg" && echo "✓ $pkg" || echo "✗ $pkg (not found in zypper)"
  done
}
install_brew() {
  for pkg in "$@"; do
    brew install "$pkg" && echo "✓ $pkg" || echo "✗ $pkg (not found in brew)"
  done
}

# Detect package manager
detect_pm() {
  if command -v paru &>/dev/null || command -v pacman &>/dev/null; then
    echo "pacman"
  elif command -v zypper &>/dev/null; then
    echo "zypper"
  elif command -v dnf &>/dev/null; then
    echo "dnf"
  elif command -v apt &>/dev/null; then
    echo "apt"
  elif command -v brew &>/dev/null; then
    echo "brew"
  else
    echo "none"
  fi
}

install_pkg() {
  case "$PM" in
    pacman)  install_pacman "$@" ;;
    zypper)  install_zypper "$@" ;;
    dnf)     install_dnf "$@" ;;
    apt)     install_apt "$@" ;;
    brew)    install_brew "$@" ;;
  esac
}

# ── Rust / Cargo ─────────────────────────────────────────────────────────────
install_rust() {
  if command -v cargo &>/dev/null; then
    echo "✓ cargo already installed"
    return 0
  fi
  echo "→ Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # Source cargo env for the rest of this session
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env" 2>/dev/null || true
  export PATH="$HOME/.cargo/bin:$PATH"
  if command -v cargo &>/dev/null; then
    echo "✓ cargo"
  else
    echo "✗ cargo (rustup install failed)"
    return 1
  fi
}

# ── Starship (with curl fallback) ────────────────────────────────────────────
install_starship() {
  echo "→ Installing starship..."
  # Try package manager first
  case "$PM" in
    pacman) install_pacman "starship" && return 0 ;;
    brew)   install_brew "starship" && return 0 ;;
    *)
      # apt/dnf/zypper often don't have starship — go straight to curl
      ;;
  esac

  # Fallback: official curl installer
  echo "→ Trying starship curl installer..."
  if curl -sS https://starship.rs/install.sh | sh -s -- -y; then
    echo "✓ starship (via curl)"
  else
    echo "✗ starship (all install methods failed)"
  fi
}

# ── Zoxide (always via cargo for correct arch) ───────────────────────────────
install_zoxide() {
  echo "→ Installing zoxide via cargo..."
  if ! command -v cargo &>/dev/null; then
    echo "✗ zoxide (cargo not available, skipping)"
    return 1
  fi
  if cargo install zoxide; then
    echo "✓ zoxide (via cargo)"
  else
    echo "✗ zoxide (cargo install failed)"
  fi
}

# ── Zellij (cargo fallback for apt/dnf/zypper) ───────────────────────────────
install_zellij() {
  echo "→ Installing zellij..."
  case "$PM" in
    pacman) install_pacman "zellij" && return 0 ;;
    brew)   install_brew "zellij" && return 0 ;;
  esac
  # Try package manager first, fall back to cargo
  case "$PM" in
    apt)    sudo apt install -y zellij 2>/dev/null && echo "✓ zellij" && return 0 ;;
    dnf)    sudo dnf install -y zellij 2>/dev/null && echo "✓ zellij" && return 0 ;;
    zypper) sudo zypper install -y zellij 2>/dev/null && echo "✓ zellij" && return 0 ;;
  esac
  echo "→ zellij not in package manager, trying cargo..."
  if command -v cargo &>/dev/null && cargo install zellij; then
    echo "✓ zellij (via cargo)"
  else
    echo "✗ zellij (all install methods failed)"
  fi
}

# ── Lazygit (GitHub binary fallback) ─────────────────────────────────────────
install_lazygit() {
  echo "→ Installing lazygit..."
  case "$PM" in
    pacman) install_pacman "lazygit" && return 0 ;;
    brew)   install_brew "lazygit" && return 0 ;;
    dnf)    sudo dnf install -y lazygit 2>/dev/null && echo "✓ lazygit" && return 0 ;;
  esac
  # apt/zypper don't have lazygit — download binary from GitHub
  echo "→ lazygit not in package manager, downloading binary..."
  local arch
  arch=$(uname -m)
  case "$arch" in
    x86_64)  arch="x86_64" ;;
    aarch64) arch="arm64" ;;
    *)       echo "✗ lazygit (unsupported arch: $arch)"; return 1 ;;
  esac
  # Get latest version tag from GitHub API
  local version
  version=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep '"tag_name"' | cut -d'"' -f4)
  if [[ -z "$version" ]]; then
    echo "✗ lazygit (could not determine latest version)"
    return 1
  fi
  local ver="${version#v}"  # strip leading 'v' for filename
  local tmp_dir
  tmp_dir=$(mktemp -d)
  local url="https://github.com/jesseduffield/lazygit/releases/download/${version}/lazygit_${ver}_Linux_${arch}.tar.gz"
  if curl -fL --progress-bar "$url" | tar -xz -C "$tmp_dir"; then
    mkdir -p "$HOME/.local/bin"
    mv "$tmp_dir/lazygit" "$HOME/.local/bin/lazygit"
    rm -rf "$tmp_dir"
    echo "✓ lazygit ${version} (via GitHub binary)"
  else
    rm -rf "$tmp_dir"
    echo "✗ lazygit (download failed)"
  fi
}

# ── JetBrains Mono Nerd Font ─────────────────────────────────────────────────
install_jetbrains_nerd_font() {
  echo "→ Installing JetBrains Mono Nerd Font..."

  # pacman has it packaged
  if [[ "$PM" == "pacman" ]]; then
    install_pacman "ttf-jetbrains-mono-nerd" && return 0
  fi

  # brew has it via cask
  if [[ "$PM" == "brew" ]]; then
    brew install --cask font-jetbrains-mono-nerd-font && echo "✓ JetBrains Mono Nerd Font (via brew)" && return 0
  fi

  # Ensure unzip is available
  if ! command -v unzip &>/dev/null; then
    echo "→ Installing unzip..."
    install_pkg "unzip"
  fi

  # Everything else: download from Nerd Fonts GitHub releases
  local font_dir="$HOME/.local/share/fonts/JetBrainsMono"
  local tmp_zip
  tmp_zip=$(mktemp /tmp/JetBrainsMonoXXXXXX)

  echo "→ Downloading JetBrains Mono Nerd Font from GitHub..."
  if curl -fL --progress-bar \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
      -o "$tmp_zip"; then
    mkdir -p "$font_dir"
    unzip -o -q "$tmp_zip" -d "$font_dir"
    rm "$tmp_zip"
    # Refresh font cache
    if command -v fc-cache &>/dev/null; then
      fc-cache -f "$font_dir"
    fi
    echo "✓ JetBrains Mono Nerd Font (installed to $font_dir)"
  else
    echo "✗ JetBrains Mono Nerd Font (download failed)"
    rm -f "$tmp_zip"
    return 1
  fi
}

# ── Tier prompt ───────────────────────────────────────────────────────────────
echo ""
echo "┌─────────────────────────────────────────────────────┐"
echo "│            Select installation tier                 │"
echo "├─────────────────────────────────────────────────────┤"
echo "│  1) core    │ fish, btop, htop, neovim, fzf,       │"
echo "│             │ starship, zoxide                      │"
echo "│             │                                       │"
echo "│  2) full    │ core + fastfetch, ranger, zellij,     │"
echo "│             │ yt-dlp, lazygit                       │"
echo "│             │                                       │"
echo "│  3) gaming  │ full + steam, lutris,                 │"
echo "│             │ gamemode, mangohud                    │"
echo "│             │                                       │"
echo "│  all tiers  │ rust, cargo, JetBrains Mono Nerd Font │"
echo "└─────────────────────────────────────────────────────┘"
echo ""
read -rp "Enter choice [1/2/3]: " TIER_CHOICE

case "$TIER_CHOICE" in
  1) PACKAGES=("${CORE_PACKAGES[@]}") ;;
  2) PACKAGES=("${FULL_PACKAGES[@]}") ;;
  3) PACKAGES=("${GAMING_PACKAGES[@]}") ;;
  *)
    echo "Invalid choice. Exiting."
    exit 1
    ;;
esac

# ── Detect package manager ────────────────────────────────────────────────────
PM=$(detect_pm)
if [[ "$PM" == "none" ]]; then
  echo "No supported package manager found. Exiting."
  exit 1
fi
echo "→ Using package manager: $PM"
echo ""

# ── Rust / Cargo (always installed first) ────────────────────────────────────
# Ensure C build tools are present (required for cargo to compile anything)
case "$PM" in
  apt)    sudo apt install -y build-essential 2>/dev/null && echo "✓ build-essential" || echo "✗ build-essential (failed)" ;;
  dnf)    sudo dnf groupinstall -y "Development Tools" 2>/dev/null && echo "✓ Development Tools" || echo "✗ Development Tools (failed)" ;;
  zypper) sudo zypper install -y -t pattern devel_basis 2>/dev/null && echo "✓ devel_basis" || echo "✗ devel_basis (failed)" ;;
esac
install_rust

# ── Install packages (excluding starship and zoxide — handled separately) ─────
MAIN_PACKAGES=()
for pkg in "${PACKAGES[@]}"; do
  if [[ "$pkg" != "starship" && "$pkg" != "zoxide" && "$pkg" != "zellij" && "$pkg" != "lazygit" ]]; then
    MAIN_PACKAGES+=("$pkg")
  fi
done

echo "Installing ${#MAIN_PACKAGES[@]} packages..."
install_pkg "${MAIN_PACKAGES[@]}"

# ── Tools with custom install logic ──────────────────────────────────────────
echo ""
install_starship
install_zoxide

# Only install zellij/lazygit if they're in the selected tier
for pkg in "${PACKAGES[@]}"; do
  [[ "$pkg" == "zellij" ]] && install_zellij
  [[ "$pkg" == "lazygit" ]] && install_lazygit
done

install_jetbrains_nerd_font

# ── Headless server setup ─────────────────────────────────────────────────────
echo ""
read -rp "Will you be using this machine as a headless server? [y/N]: " SERVER_CHOICE

if [[ "${SERVER_CHOICE,,}" == "y" ]]; then
  echo ""
  echo "→ Configuring machine for headless server use..."

  # 1. Disable sleep/suspend entirely
  echo "→ Disabling sleep and suspend targets..."
  sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target \
    && echo "✓ Sleep/suspend disabled" || echo "✗ Failed to disable sleep targets"

  # 2. Ignore lid close events
  echo "→ Configuring lid switch to do nothing..."
  LOGIND_CONF="/etc/systemd/logind.conf"
  if grep -q "^HandleLidSwitch=" "$LOGIND_CONF"; then
    sudo sed -i 's/^HandleLidSwitch=.*/HandleLidSwitch=ignore/' "$LOGIND_CONF"
  else
    echo "HandleLidSwitch=ignore" | sudo tee -a "$LOGIND_CONF" > /dev/null
  fi
  if grep -q "^HandleLidSwitchDocked=" "$LOGIND_CONF"; then
    sudo sed -i 's/^HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/' "$LOGIND_CONF"
  else
    echo "HandleLidSwitchDocked=ignore" | sudo tee -a "$LOGIND_CONF" > /dev/null
  fi
  sudo systemctl restart systemd-logind && echo "✓ Lid switch configured" || echo "✗ Failed to apply lid switch config"

  # 3. Install and enable SSH
  echo "→ Installing and enabling SSH..."
  case "$PM" in
    apt)    sudo apt install -y openssh-server 2>/dev/null ;;
    dnf)    sudo dnf install -y openssh-server 2>/dev/null ;;
    zypper) sudo zypper install -y openssh 2>/dev/null ;;
    pacman) install_pacman "openssh" ;;
    brew)   echo "→ Skipping SSH install (not needed on macOS)" ;;
  esac
  sudo systemctl enable ssh 2>/dev/null || sudo systemctl enable sshd 2>/dev/null
  sudo systemctl start ssh 2>/dev/null || sudo systemctl start sshd 2>/dev/null
  echo "✓ SSH enabled and running"

  # 4. Enable automatic security updates (apt only)
  if [[ "$PM" == "apt" ]]; then
    echo "→ Enabling unattended security upgrades..."
    sudo apt install -y unattended-upgrades 2>/dev/null
    echo 'Unattended-Upgrade::Automatic-Reboot "false";' \
      | sudo tee /etc/apt/apt.conf.d/99auto-reboot > /dev/null
    sudo dpkg-reconfigure -f noninteractive unattended-upgrades \
      && echo "✓ Unattended upgrades enabled" || echo "✗ Failed to enable unattended upgrades"
  fi

  # 5. Enable Tailscale on boot if installed
  if command -v tailscale &>/dev/null; then
    echo "→ Enabling Tailscale on boot..."
    sudo systemctl enable tailscaled \
      && echo "✓ Tailscale enabled on boot" || echo "✗ Failed to enable Tailscale"
  fi

  echo ""
  echo "✓ Headless server setup complete."
  echo "  You can now close the lid and manage this machine over SSH or Tailscale."
  echo "  Remember to reserve a static LAN IP for this machine in your router's DHCP settings."
fi

echo ""
echo "Done!"
