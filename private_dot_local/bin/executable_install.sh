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
  source "$HOME/.cargo/env"
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

# ── Zoxide (with cargo fallback) ─────────────────────────────────────────────
install_zoxide() {
  echo "→ Installing zoxide..."
  # Try package manager first
  case "$PM" in
    pacman) install_pacman "zoxide" && return 0 ;;
    brew)   install_brew "zoxide" && return 0 ;;
    apt)
      sudo apt install -y zoxide 2>/dev/null && echo "✓ zoxide" && return 0
      ;;
    dnf)
      sudo dnf install -y zoxide 2>/dev/null && echo "✓ zoxide" && return 0
      ;;
    zypper)
      sudo zypper install -y zoxide 2>/dev/null && echo "✓ zoxide" && return 0
      ;;
  esac

  # Fallback: cargo istall
  echo "→ zoxide not in package manager, trying cargo..."
  if ! command -v cargo &>/dev/null; then
    install_rust || { echo "✗ zoxide (cargo unavailable)"; return 1; }
  fi
  if cargo install zoxide; then
    echo "✓ zoxide (via cargo)"
  else
    echo "✗ zoxide (cargo install failed)"
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

  # Everything else: download from Nerd Fonts GitHub releases
  local font_dir="$HOME/.local/share/fonts/JetBrainsMono"
  local tmp_zip
  tmp_zip=$(mktemp /tmp/JetBrainsMono.XXXXXX.zip)

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
echo "┌─────────────────────────────────────────┐"
echo "│         Select installation tier         │"
echo "├─────────────────────────────────────────┤"
echo "│  1) core    fish, btop, htop, neovim,   │"
echo "│             fzf, starship, zoxide        │"
echo "│                                          │"
echo "│  2) full    core + fastfetch, ranger,    │"
echo "│             zellij, yt-dlp, lazygit      │"
echo "│                                          │"
echo "│  3) gaming  full + steam, lutris,        │"
echo "│             gamemode, mangohud           │"
echo "└─────────────────────────────────────────┘"
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

# ── Install packages (excluding starship and zoxide — handled separately) ─────
MAIN_PACKAGES=()
for pkg in "${PACKAGES[@]}"; do
  if [[ "$pkg" != "starship" && "$pkg" != "zoxide" ]]; then
    MAIN_PACKAGES+=("$pkg")
  fi
done

echo "Installing ${#MAIN_PACKAGES[@]} packages..."
install_pkg "${MAIN_PACKAGES[@]}"

# ── Starship and zoxide with fallbacks ────────────────────────────────────────
echo ""
install_starship
install_zoxide
install_jetbrains_nerd_font

echo ""
echo "Done!"n
