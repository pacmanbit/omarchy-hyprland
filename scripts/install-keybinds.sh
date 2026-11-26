#!/usr/bin/env bash
# Keybinds-only installer for Hyprland (supports both Omarchy Lua and standard hyprland.conf)

set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_DIR=$(cd -- "$SCRIPT_DIR/.." && pwd)

MODE=""
UNINSTALL=0
YES=0

usage() {
  cat <<EOF
Usage: ./scripts/install-keybinds.sh [OPTIONS]

Installs ONLY Hyprland keybindings without touching your bar, shell, or theme.

Options:
  --lua        Install Lua overrides (~/.config/hypr/bindings.lua) for Omarchy / Hyprland Lua
  --conf       Install standalone Hyprland bindings (~/.config/hypr/keybinds-omarchy.conf) and source it in hyprland.conf
  --uninstall  Remove installed keybinds / restore backup
  -y, --yes    Non-interactive mode
  -h, --help   Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lua) MODE="lua"; shift ;;
    --conf) MODE="conf"; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    -y|--yes) YES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

info() { printf "\033[1;34m[keybinds]\033[0m %s\n" "$*"; }
ok()   { printf "\033[1;32m[ok]\033[0m       %s\n" "$*"; }

HYPR_DIR="$HOME/.config/hypr"
BACKUP_DIR="$HOME/.local/state/omarchy-hyprland-backups/keybinds"

if (( UNINSTALL )); then
  if [[ -f "$BACKUP_DIR/bindings.lua" ]]; then
    cp -a "$BACKUP_DIR/bindings.lua" "$HYPR_DIR/bindings.lua"
    ok "Restored ~/.config/hypr/bindings.lua from backup."
  fi
  if [[ -f "$HYPR_DIR/hyprland.conf" ]] && grep -q "# >>> omarchy-keybinds >>>" "$HYPR_DIR/hyprland.conf"; then
    python3 -c '
p = "'"$HYPR_DIR"'/hyprland.conf"
with open(p) as f: lines = f.readlines()
out = []; skip = False
for line in lines:
    if "# >>> omarchy-keybinds >>>" in line: skip = True; continue
    if "# <<< omarchy-keybinds <<<" in line: skip = False; continue
    if not skip: out.append(line)
with open(p, "w") as f: f.writelines(out)
'
    ok "Removed source block from ~/.config/hypr/hyprland.conf."
  fi
  rm -f "$HYPR_DIR/keybinds-omarchy.conf"
  if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
  fi
  ok "Keybinds uninstalled."
  exit 0
fi

# Auto-detect Lua vs hyprland.conf
if [[ -z "$MODE" ]]; then
  if [[ -f "$HYPR_DIR/hyprland.lua" ]]; then
    MODE="lua"
  elif [[ -f "$HYPR_DIR/hyprland.conf" ]]; then
    MODE="conf"
  elif (( YES )); then
    MODE="conf"
  else
    echo "Select your Hyprland config style:"
    echo "  1) Omarchy / Hyprland Lua (bindings.lua)"
    echo "  2) Standard Hyprland (hyprland.conf)"
    read -r -p "Choice [1/2]: " ch || true
    case "$ch" in
      1) MODE="lua" ;;
      *) MODE="conf" ;;
    esac
  fi
fi

mkdir -p "$HYPR_DIR" "$BACKUP_DIR" "$HOME/.local/bin"

# Install omarchy-toggle-hdr helper so SUPER+SHIFT+H / SUPER+F12 work everywhere
cp -a "$REPO_DIR/runtime/share/omarchy/bin/omarchy-toggle-hdr" "$HOME/.local/bin/omarchy-toggle-hdr"
chmod +x "$HOME/.local/bin/omarchy-toggle-hdr"

if [[ "$MODE" == "lua" ]]; then
  if [[ -f "$HYPR_DIR/bindings.lua" ]]; then
    cp -a "$HYPR_DIR/bindings.lua" "$BACKUP_DIR/bindings.lua"
    info "Backed up existing ~/.config/hypr/bindings.lua"
  fi
  cp -a "$REPO_DIR/config/hypr/bindings.lua" "$HYPR_DIR/bindings.lua"
  ok "Installed ~/.config/hypr/bindings.lua"
else
  TARGET_CONF="$HYPR_DIR/keybinds-omarchy.conf"
  cp -a "$REPO_DIR/config/hypr/keybinds-standalone.conf" "$TARGET_CONF"
  ok "Installed $TARGET_CONF"

  MAIN_CONF="$HYPR_DIR/hyprland.conf"
  [[ -f "$MAIN_CONF" ]] || touch "$MAIN_CONF"
  cp -a "$MAIN_CONF" "$BACKUP_DIR/hyprland.conf.$(date +%Y%m%d-%H%M%S)"
  if ! grep -q "# >>> omarchy-keybinds >>>" "$MAIN_CONF"; then
    cat >> "$MAIN_CONF" <<'EOF'

# >>> omarchy-keybinds >>>
source = ~/.config/hypr/keybinds-omarchy.conf
# <<< omarchy-keybinds <<<
EOF
    ok "Added source line to ~/.config/hypr/hyprland.conf"
  fi
fi

if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload >/dev/null 2>&1 && ok "Reloaded Hyprland configuration." || true
fi

ok "Keybinds-only install complete!"
