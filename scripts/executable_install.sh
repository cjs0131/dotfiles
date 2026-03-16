#!/bin/bash

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

echo "Select package manager:"
echo "1) apt  2) dnf  3) pacman  4) zypper  5) brew"
read -p "Choice: " pm

install_apt() {
    sudo apt update
    sudo apt install -y "${PACKAGES[@]}"
}

install_dnf() {
    sudo dnf install -y "${PACKAGES[@]}"
}

install_pacman() {
    sudo pacman -Sy --noconfirm "${PACKAGES[@]}"
}

install_zypper() {
    sudo zypper install -y "${PACKAGES[@]}"
}

install_brew() {
    brew install "${PACKAGES[@]}"
}

echo "Installing ${#PACKAGES[@]} packages..."

case $pm in
    1) install_apt ;;
    2) install_dnf ;;
    3) install_pacman ;;
    4) install_zypper ;;
    5) install_brew ;;
    *) echo "Invalid"; exit 1 ;;
esac

echo "Done!"
