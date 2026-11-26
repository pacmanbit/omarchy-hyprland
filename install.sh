#!/usr/bin/env bash
# Installer for omarchy-hyprland
# Supports BOTH:
#   --fresh     Fresh system / clean Arch or Linux Hyprland setup
#   --existing  Existing Hyprland / Linux system (safe backups + selective overrides)

set -euo pipefail

REPO_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

MODE=""
NON_INTERACTIVE=0
SKIP_DEPS=0
KEEP_MONITORS=0
USE_DUAL_MONITORS=0
KEEP_KITTY=0
KEEP_GTK=0
KEEP_INPUT=0
ENABLE_PRAYER=0
PRAYER_CITY=""
PRAYER_COUNTRY=""
PRAYER_METHOD=""

usage() {
  cat <<EOF
Usage: ./install.sh [OPTIONS]

Modes:
  --fresh               Fresh install mode (installs packages + full config + shell env)
  --existing            Existing Hyprland mode (backs up current configs + preserves monitors if chosen)

Options:
  --non-interactive, -y Do not prompt; use defaults / flags
  --skip-deps           Skip package manager dependency installation
  --keep-monitors       Keep your existing ~/.config/hypr/monitors.lua (or .conf)
  --dual-monitors       Use the included DP-1 1440p@180 + HDMI-A-1 vertical example
  --keep-kitty          Keep your existing ~/.config/kitty/kitty.conf
  --keep-gtk            Keep your existing ~/.config/gtk-3.0/settings.ini
  --keep-input          Keep your existing ~/.config/hypr/input.lua
  --with-prayer         Also install optional Islamic Prayer Times plugin (off by default)
  --prayer-city CITY    Set Islamic Prayer Times city (implies --with-prayer, default: Al-Karak)
  --prayer-country CTRY Set Islamic Prayer Times country (implies --with-prayer, default: Jordan)
  --prayer-method METH  Set AlAdhan method (implies --with-prayer, default: JORDAN)
  -h, --help            Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --fresh) MODE="fresh"; shift ;;
    --existing) MODE="existing"; shift ;;
    --non-interactive|-y) NON_INTERACTIVE=1; shift ;;
    --skip-deps) SKIP_DEPS=1; shift ;;
    --keep-monitors) KEEP_MONITORS=1; shift ;;
    --dual-monitors) USE_DUAL_MONITORS=1; shift ;;
    --keep-kitty) KEEP_KITTY=1; shift ;;
    --keep-gtk) KEEP_GTK=1; shift ;;
    --keep-input) KEEP_INPUT=1; shift ;;
    --with-prayer) ENABLE_PRAYER=1; shift ;;
    --prayer-city) PRAYER_CITY="${2:-}"; ENABLE_PRAYER=1; shift 2 ;;
    --prayer-country) PRAYER_COUNTRY="${2:-}"; ENABLE_PRAYER=1; shift 2 ;;
    --prayer-method) PRAYER_METHOD="${2:-}"; ENABLE_PRAYER=1; shift 2 ;;
    --no-prayer) ENABLE_PRAYER=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

info() { printf "\033[1;34m[install]\033[0m %s\n" "$*"; }
ok()   { printf "\033[1;32m[ok]\033[0m      %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m    %s\n" "$*"; }

ask_yn() {
  local prompt="$1" default="${2:-y}" reply
  if (( NON_INTERACTIVE )); then
    [[ "$default" == "y" ]]
    return
  fi
  if [[ "$default" == "y" ]]; then
    read -r -p "$prompt [Y/n]: " reply || true
    [[ -z "$reply" || "$reply" =~ ^[Yy]$ ]]
  else
    read -r -p "$prompt [y/N]: " reply || true
    [[ "$reply" =~ ^[Yy]$ ]]
  fi
}

if (( EUID == 0 )); then
  echo "Do not run install.sh as root (it installs to \$HOME and invokes sudo when needed)." >&2
  exit 1
fi

# Auto-detect mode interactively if not specified
if [[ -z "$MODE" ]]; then
  if (( NON_INTERACTIVE )); then
    if [[ -d "$HOME/.config/hypr" || -d "$HOME/.config/omarchy" ]]; then
      MODE="existing"
    else
      MODE="fresh"
    fi
  else
    echo ""
    echo "=============================================="
    echo "  Omarchy + Hyprland Portable Setup Installer"
    echo "=============================================="
    echo "  1) Fresh Install    — Install packages, Omarchy runtime, configs, theme, shell env"
    echo "  2) Existing System  — Backup existing Hyprland/Omarchy configs & install cleanly"
    echo ""
    read -r -p "Choose install mode [1/2] (default: 2 if ~/.config/hypr exists): " choice || true
    case "$choice" in
      1) MODE="fresh" ;;
      2) MODE="existing" ;;
      *)
        if [[ -d "$HOME/.config/hypr" || -d "$HOME/.config/omarchy" ]]; then
          MODE="existing"
        else
          MODE="fresh"
        fi
        ;;
    esac
  fi
fi

info "Install mode: $MODE"

# Interactive choices for existing systems
if [[ "$MODE" == "existing" && $NON_INTERACTIVE -eq 0 ]]; then
  if [[ -f "$HOME/.config/hypr/monitors.lua" || -f "$HOME/.config/hypr/monitors.conf" ]]; then
    ask_yn "Keep your existing Hyprland monitor config?" "y" && KEEP_MONITORS=1
  fi
  if [[ -f "$HOME/.config/hypr/input.lua" ]]; then
    ask_yn "Keep your existing Hyprland keyboard/input config (repo defaults to us,ara)? " "n" && KEEP_INPUT=1
  fi
  if [[ -f "$HOME/.config/kitty/kitty.conf" ]]; then
    ask_yn "Replace your kitty.conf with the repo's Kitty config (backup will be saved)?" "y" || KEEP_KITTY=1
  fi
  if [[ -f "$HOME/.config/gtk-3.0/settings.ini" ]]; then
    ask_yn "Replace your GTK 3.0 settings.ini (backup will be saved)?" "y" || KEEP_GTK=1
  fi
fi

# 1. Dependencies
if (( SKIP_DEPS == 0 )); then
  if [[ "$MODE" == "fresh" ]]; then
    bash "$REPO_DIR/scripts/deps.sh" $( (( NON_INTERACTIVE )) && echo "--yes" )
  else
    if ! bash "$REPO_DIR/scripts/deps.sh" --check; then
      if ask_yn "Install missing dependencies now?" "y"; then
        bash "$REPO_DIR/scripts/deps.sh" $( (( NON_INTERACTIVE )) && echo "--yes" )
      else
        warn "Continuing without installing missing dependencies."
      fi
    fi
  fi
fi

# 2. Backup existing configs
TS=$(date +%Y%m%d-%H%M%S)
BACKUP_ROOT="$HOME/.local/state/omarchy-hyprland-backups/$TS"
mkdir -p "$BACKUP_ROOT"

backup_path() {
  local target="$1"
  local rel="${target#"$HOME"/}"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$BACKUP_ROOT/$(dirname "$rel")"
    cp -a "$target" "$BACKUP_ROOT/$rel"
    info "Backed up ~/$rel"
  fi
}

backup_path "$HOME/.config/hypr"
backup_path "$HOME/.config/omarchy"
backup_path "$HOME/.config/kitty/kitty.conf"
backup_path "$HOME/.config/gtk-3.0/settings.ini"
backup_path "$HOME/.local/share/omarchy"

# Save existing monitors/input/kitty/gtk if requested
PRESERVE_DIR=$(mktemp -d)
trap 'rm -rf "$PRESERVE_DIR"' EXIT
if (( KEEP_MONITORS )); then
  [[ -f "$HOME/.config/hypr/monitors.lua" ]] && cp -a "$HOME/.config/hypr/monitors.lua" "$PRESERVE_DIR/monitors.lua"
  [[ -f "$HOME/.config/hypr/monitors.conf" ]] && cp -a "$HOME/.config/hypr/monitors.conf" "$PRESERVE_DIR/monitors.conf"
fi
if (( KEEP_INPUT )) && [[ -f "$HOME/.config/hypr/input.lua" ]]; then
  cp -a "$HOME/.config/hypr/input.lua" "$PRESERVE_DIR/input.lua"
fi

# 3. Install Omarchy user-space runtime (~/.local/share/omarchy + ~/.local/bin/omarchy*)
info "Installing Omarchy runtime to ~/.local/share/omarchy..."
mkdir -p "$HOME/.local/share/omarchy" "$HOME/.local/bin"
rsync -a --delete "$REPO_DIR/runtime/share/omarchy/" "$HOME/.local/share/omarchy/"

info "Linking Omarchy executables into ~/.local/bin..."
for exe in "$HOME/.local/share/omarchy/bin/"omarchy*; do
  [[ -e "$exe" ]] || continue
  chmod +x "$exe"
  name=$(basename "$exe")
  if [[ -e "$HOME/.local/bin/$name" && ! -L "$HOME/.local/bin/$name" ]]; then
    mkdir -p "$BACKUP_ROOT/.local/bin"
    cp -a "$HOME/.local/bin/$name" "$BACKUP_ROOT/.local/bin/$name"
  fi
  ln -sf "$exe" "$HOME/.local/bin/$name"
done

# 4. Install user configs
info "Installing Hyprland Lua configs to ~/.config/hypr..."
mkdir -p "$HOME/.config/hypr"
# Move aside any old hyprland.conf so Hyprland loads hyprland.lua
if [[ -f "$HOME/.config/hypr/hyprland.conf" ]]; then
  mv "$HOME/.config/hypr/hyprland.conf" "$BACKUP_ROOT/hyprland.conf.disabled"
  warn "Moved existing ~/.config/hypr/hyprland.conf to backup so Hyprland loads hyprland.lua."
fi
rsync -a "$REPO_DIR/config/hypr/" "$HOME/.config/hypr/"
chmod +x "$HOME/.config/hypr/scripts/Hyprsunset.sh"

if (( USE_DUAL_MONITORS )); then
  cp -a "$HOME/.config/hypr/monitors.dual-hdr.example.lua" "$HOME/.config/hypr/monitors.lua"
  info "Applied dual-monitor HDR preset to ~/.config/hypr/monitors.lua."
fi
if (( KEEP_MONITORS )); then
  [[ -f "$PRESERVE_DIR/monitors.lua" ]] && cp -a "$PRESERVE_DIR/monitors.lua" "$HOME/.config/hypr/monitors.lua"
  [[ -f "$PRESERVE_DIR/monitors.conf" ]] && cp -a "$PRESERVE_DIR/monitors.conf" "$HOME/.config/hypr/monitors.conf"
  info "Restored your preserved monitor configuration."
fi
if (( KEEP_INPUT )) && [[ -f "$PRESERVE_DIR/input.lua" ]]; then
  cp -a "$PRESERVE_DIR/input.lua" "$HOME/.config/hypr/input.lua"
  info "Restored your preserved input configuration."
fi

info "Installing Omarchy bar, plugins, scripts, and themes to ~/.config/omarchy..."
mkdir -p "$HOME/.config/omarchy"
rsync -a "$REPO_DIR/config/omarchy/" "$HOME/.config/omarchy/"
chmod +x "$HOME/.config/omarchy/bar/scripts/"*

# Optional Islamic Prayer Times plugin (disabled by default)
if (( ENABLE_PRAYER == 0 && NON_INTERACTIVE == 0 )); then
  ask_yn "Install optional Islamic Prayer Times bar widget (github.com/pacmanbit/omarchy-prayer-times)?" "n" && ENABLE_PRAYER=1
fi

if (( ENABLE_PRAYER )); then
  PLUGIN_DIR="$HOME/.config/omarchy/plugins/pacmanbit.prayer-times"
  if command -v git >/dev/null 2>&1; then
    info "Installing optional Islamic Prayer Times plugin..."
    rm -rf "$PLUGIN_DIR"
    if git clone --depth 1 https://github.com/pacmanbit/omarchy-prayer-times.git "$PLUGIN_DIR"; then
      chmod +x "$PLUGIN_DIR/scripts/prayer-times"
      if [[ -n "$PRAYER_CITY" || -n "$PRAYER_COUNTRY" || -n "$PRAYER_METHOD" ]]; then
        cat > "$HOME/.config/prayer-times.json" <<EOF
{
  "city": "${PRAYER_CITY:-Al-Karak}",
  "country": "${PRAYER_COUNTRY:-Jordan}",
  "method": "${PRAYER_METHOD:-JORDAN}",
  "now_window": 20,
  "close_threshold": 30,
  "now_color": "#50FA7B",
  "close_color": "#FAB387"
}
EOF
      fi
      python3 -c '
import json
p = "'"$HOME"'/.config/omarchy/shell.json"
with open(p) as f: d = json.load(f)
center = d["bar"]["layout"]["center"]
if not any(x.get("id") == "pacmanbit.prayer-times" for x in center):
    idx = next((i + 1 for i, x in enumerate(center) if x.get("id") == "omarchy.clock"), len(center))
    center.insert(idx, {"id": "pacmanbit.prayer-times"})
with open(p, "w") as f: json.dump(d, f, indent=2)
'
      ok "Installed and enabled pacmanbit.prayer-times in bar layout."
    else
      warn "Could not clone omarchy-prayer-times; skipping optional prayer widget."
    fi
  else
    warn "git not found; skipping optional prayer widget."
  fi
fi

if (( KEEP_KITTY == 0 )); then
  mkdir -p "$HOME/.config/kitty"
  cp -a "$REPO_DIR/config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
  info "Installed ~/.config/kitty/kitty.conf."
fi

if (( KEEP_GTK == 0 )); then
  mkdir -p "$HOME/.config/gtk-3.0"
  cp -a "$REPO_DIR/config/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
  info "Installed ~/.config/gtk-3.0/settings.ini."
fi

# 5. Post-install: shell PATH, active theme, live reload
bash "$REPO_DIR/scripts/post-install.sh" "$BACKUP_ROOT"

echo ""
ok "Installation complete!"
echo "   Backup saved at: $BACKUP_ROOT"
echo "   To restore your previous setup: ./uninstall.sh"
if [[ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
  echo "   Log in to Hyprland (from TTY run 'Hyprland' or select Hyprland in your display manager)."
fi
