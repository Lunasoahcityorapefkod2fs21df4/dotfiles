#!/bin/bash

# Migrate from hyprpaper to swww

DOTFILES_DIR="$HOME/.local/share/dotfiles"
source "$DOTFILES_DIR/install/lib/helpers.sh"

# Install swww if not present
if ! pacman -Qq swww &>/dev/null; then
  log_info "Installing swww..."
  $(get_aur_helper) -S swww --noconfirm 2>/dev/null || true
fi

# Stop and disable hyprpaper
systemctl --user disable hyprpaper.service 2>/dev/null || true
systemctl --user stop hyprpaper.service 2>/dev/null || true
pkill hyprpaper 2>/dev/null || true

# Remove old hyprpaper config
rm -f "$HOME/.config/hypr/hyprpaper.conf"

# Remove obsolete tinte settings.json, replace with config.toml
rm -f "$HOME/.config/tinte/settings.json"

TINTE_THEMES_DIR="$HOME/.local/share/dotfiles/themes/tinte"
TINTE_TEMPLATES="$DOTFILES_DIR/tinte-templates"

mkdir -p "$HOME/.config/tinte"
cat > "$HOME/.config/tinte/config.toml" << EOF
[config]
wallpaper_cmd = "swww img {path} --transition-type fade --transition-duration 1"
post_hook = "theme-set tinte {path}"

[templates.ghostty]
input_path = "$TINTE_TEMPLATES/ghostty.conf"
output_path = "$TINTE_THEMES_DIR/ghostty.conf"
post_hook = "killall -SIGUSR2 ghostty"

[templates.waybar]
input_path = "$TINTE_TEMPLATES/waybar.css"
output_path = "$TINTE_THEMES_DIR/waybar.css"

[templates.mako]
input_path = "$TINTE_TEMPLATES/mako.ini"
output_path = "$TINTE_THEMES_DIR/mako.ini"
post_hook = "makoctl reload"

[templates.hyprland]
input_path = "$TINTE_TEMPLATES/hyprland.conf"
output_path = "$TINTE_THEMES_DIR/hyprland.conf"

[templates.hyprlock]
input_path = "$TINTE_TEMPLATES/hyprlock.conf"
output_path = "$TINTE_THEMES_DIR/hyprlock.conf"

[templates.walker]
input_path = "$TINTE_TEMPLATES/walker.css"
output_path = "$TINTE_THEMES_DIR/walker.css"

[templates.swayosd]
input_path = "$TINTE_TEMPLATES/swayosd.css"
output_path = "$TINTE_THEMES_DIR/swayosd.css"

[templates.btop]
input_path = "$TINTE_TEMPLATES/btop.theme"
output_path = "$TINTE_THEMES_DIR/btop.theme"

[templates.gtk]
input_path = "$TINTE_TEMPLATES/gtk.css"
output_path = "$TINTE_THEMES_DIR/gtk.css"

[templates.neovim]
input_path = "$TINTE_TEMPLATES/neovim.lua"
output_path = "$TINTE_THEMES_DIR/neovim.lua"
EOF

# Start swww and set current wallpaper
swww-daemon &
sleep 1
CURRENT_BG=$(readlink -f "$HOME/.local/share/dotfiles/current/background" 2>/dev/null)
if [ -n "$CURRENT_BG" ] && [ -f "$CURRENT_BG" ]; then
  swww img "$CURRENT_BG" --transition-type fade --transition-duration 1
fi

log_success "Migrated from hyprpaper to swww"
notify-send -t 5000 "Wallpaper Migration" "Migrated from hyprpaper to swww!" 2>/dev/null || true
