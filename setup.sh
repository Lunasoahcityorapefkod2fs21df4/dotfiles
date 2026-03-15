#!/bin/bash

set -e

DOTFILES_DIR="$HOME/.local/share/dotfiles"
REPO_URL="https://github.com/Luna4781/dotfiles.git"

echo "=============="
echo "Dotfiles Setup"
echo "=============="
echo

# Check if dotfiles directory already exists
if [ -d "$DOTFILES_DIR" ]; then
    echo "ERROR: $DOTFILES_DIR already exists!"
    echo "If you want to reinstall, please remove or backup the existing directory first:"
    echo "  mv ~/.local/share/dotfiles ~/.local/share/dotfiles.backup"
    exit 1
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing git..."
    sudo pacman -S --noconfirm git
    echo "Git installed successfully!"
fi

# Create .config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Create .local/share/dotfiles directory
mkdir -p "$HOME/.local/share/dotfiles"

# Clone the dotfiles repository
echo "Cloning dotfiles repository..."
git clone "$REPO_URL" "$DOTFILES_DIR"

echo
echo "Repository cloned successfully!"

# ===== CRITICAL: Fix line endings and permissions =====
# Files may have CRLF endings if committed from Windows.
# Hyprland, bash, and other Linux tools choke on \r characters.
echo "Fixing line endings..."
find "$DOTFILES_DIR" -type f \( -name "*.sh" -o -name "*.conf" -o -name "*.css" -o -name "*.toml" -o -name "*.json" -o -name "*.ini" -o -name "*.xml" -o -name "*.lua" -o -name "*.theme" -o -name "*.service" -o -name "*.txt" -o -name "*.md" -o -name "config" -o -name "pkgs.txt" \) -exec sed -i 's/\r$//' {} +
# Fix scripts without extensions (bin/*, install/*)
find "$DOTFILES_DIR/bin" "$DOTFILES_DIR/install" -type f -exec sed -i 's/\r$//' {} +
# Fix all hypr conf files
find "$DOTFILES_DIR" -path "*/hypr/*" -type f -exec sed -i 's/\r$//' {} +
# Fix walker config/themes
find "$DOTFILES_DIR" -path "*/walker/*" -type f -exec sed -i 's/\r$//' {} +
# Fix waybar config/themes
find "$DOTFILES_DIR" -path "*/waybar/*" -type f -exec sed -i 's/\r$//' {} +
# Fix ghostty config
find "$DOTFILES_DIR" -path "*/ghostty/*" -type f -exec sed -i 's/\r$//' {} +
# Fix mako config
find "$DOTFILES_DIR" -path "*/mako/*" -type f -exec sed -i 's/\r$//' {} +

# Ensure all scripts are executable
chmod +x "$DOTFILES_DIR/bin/"*
chmod +x "$DOTFILES_DIR/install/"*
chmod +x "$DOTFILES_DIR/install/lib/"*
chmod +x "$DOTFILES_DIR/updates/"*.sh 2>/dev/null || true
chmod +x "$DOTFILES_DIR/setup.sh"

echo "Starting installation..."
echo

# Run the installer
bash "$DOTFILES_DIR/install/install"
