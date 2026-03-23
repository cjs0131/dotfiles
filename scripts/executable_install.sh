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
    "zoxide"
    "neovim"
    "fzf"
    "lazygit"
)

install_apt() {
    sudo apt update
    for pkg in "$@"; do
        sudo apt install -y "$pkg" 2>/dev/null && echo "✓ $pkg" || echo "✗ $pkg (not found)"
    done
}
install_dnf() { sudo dnf install -y "$@"; }
install_pacman() {
    if command -v paru &>/dev/null; then
        paru -S --noconfirm "$@"
    else
        sudo pacman -S --noconfirm "$@"
    fi
}
install_zypper() { sudo zypper install -y --no-recommends "$@"; }
install_brew() { brew install "$@"; }

echo "Installing ${#PACKAGES[@]} packages..."

if command -v paru &>/dev/null || command -v pacman &>/dev/null; then
    install_pacman "${PACKAGES[@]}"
elif command -v zypper &>/dev/null; then
    install_zypper "${PACKAGES[@]}"
elif command -v dnf &>/dev/null; then
    install_dnf "${PACKAGES[@]}"
elif command -v apt &>/dev/null; then
    install_apt "${PACKAGES[@]}"
elif command -v brew &>/dev/null; then
    install_brew "${PACKAGES[@]}"
else
    echo "No supported package manager found"
    exit 1
fi

echo "Done!"
