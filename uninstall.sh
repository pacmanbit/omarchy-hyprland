#!/usr/bin/env bash
# Restores the most recent backup created by install.sh, or removes installed files.

set -euo pipefail

BACKUP_PTR="$HOME/.local/state/omarchy-hyprland-backups/latest"

info() { printf "\033[1;34m[uninstall]\033[0m %s\n" "$*"; }
ok()   { printf "\033[1;32m[ok]\033[0m        %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m      %s\n" "$*"; }

# Remove managed ~/.local/bin symlinks pointing into ~/.local/share/omarchy/bin
for link in "$HOME/.local/bin/"omarchy*; do
  [[ -L "$link" ]] || continue
  target=$(readlink "$link" || true)
  if [[ "$target" == "$HOME/.local/share/omarchy/bin/"* ]]; then
    rm -f "$link"
  fi
done

if [[ -f "$BACKUP_PTR" ]]; then
  BACKUP_DIR=$(cat "$BACKUP_PTR")
  if [[ -d "$BACKUP_DIR" ]]; then
    info "Restoring backup from $BACKUP_DIR..."
    for item in .config/hypr .config/omarchy .config/kitty/kitty.conf .config/gtk-3.0/settings.ini .local/share/omarchy; do
      if [[ -e "$BACKUP_DIR/$item" || -L "$BACKUP_DIR/$item" ]]; then
        rm -rf "${HOME:?}/$item"
        mkdir -p "$HOME/$(dirname "$item")"
        cp -a "$BACKUP_DIR/$item" "$HOME/$item"
        info "Restored ~/$item"
      fi
    done
    if [[ -d "$BACKUP_DIR/.local/bin" ]]; then
      cp -a "$BACKUP_DIR/.local/bin/"* "$HOME/.local/bin/" 2>/dev/null || true
    fi
    if [[ -f "$BACKUP_DIR/hyprland.conf.disabled" ]]; then
      mv "$BACKUP_DIR/hyprland.conf.disabled" "$HOME/.config/hypr/hyprland.conf"
      info "Restored ~/.config/hypr/hyprland.conf"
    fi
    ok "Backup restored."
    exit 0
  fi
fi

warn "No backup directory found at $BACKUP_PTR."
read -r -p "Remove installed ~/.config/hypr, ~/.config/omarchy, and ~/.local/share/omarchy? [y/N]: " ans || true
if [[ "$ans" =~ ^[Yy]$ ]]; then
  rm -rf "$HOME/.config/hypr" "$HOME/.config/omarchy" "$HOME/.local/share/omarchy"
  ok "Removed omarchy-hyprland configs and runtime."
else
  info "Cancelled."
fi
