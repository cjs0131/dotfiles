#!/bin/bash

echo "Select package manager:"
echo "1) apt  2) dnf  3) pacman  4) zypper  5) brew"
read -p "Choice: " pm

PACKAGES=(
    "fish"
    "fastfetch"
    "btop"
    "htop"
    "ranger"
    "starship"
    "chezmoi"
    "zellij"
    "firefox"
    "vlc"
    "zoxide"
)

echo "Installing ${#PACKAGES[@]} packages..."

install_apt() {
    sudo apt update
    for pkg in "$@"; do
        sudo apt install -y "$pkg" 2>/dev/null && echo "✓ $pkg" || echo "✗ $pkg (not found)"
    done
}

install_dnf() { sudo dnf install -y "$@"; }
install_pacman() { sudo pacman -Sy --noconfirm "$@"; }
install_zypper() { sudo zypper install -y "$@"; }
install_brew() { brew install "$@"; }

case $pm in
    1) install_apt "${PACKAGES[@]}" ;;
    2) install_dnf "${PACKAGES[@]}" ;;
    3) install_pacman "${PACKAGES[@]}" ;;
    4) install_zypper "${PACKAGES[@]}" ;;
    5) install_brew "${PACKAGES[@]}" ;;
    *) echo "Invalid"; exit 1 ;;
esac

echo "Done!"
