#!/usr/bin/env bash
# Post-install setup: shell environment, initial theme state, and live reload

set -euo pipefail

BACKUP_ROOT="${1:-}"
info() { printf "\033[1;34m[post]\033[0m    %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m    %s\n" "$*"; }

# 1. Record latest backup pointer for uninstall.sh
mkdir -p "$HOME/.local/state/omarchy-hyprland-backups"
if [[ -n "$BACKUP_ROOT" && -d "$BACKUP_ROOT" ]]; then
  printf '%s\n' "$BACKUP_ROOT" > "$HOME/.local/state/omarchy-hyprland-backups/latest"
fi

# 2. Ensure OMARCHY_PATH and ~/.local/bin are exported in ~/.bashrc and ~/.zshrc (if present)
append_env_block() {
  local rc_file="$1"
  [[ -f "$rc_file" ]] || return 0
  if grep -q "# >>> omarchy-hyprland >>>" "$rc_file" 2>/dev/null; then
    return 0
  fi
  cat >> "$rc_file" <<'EOF'

# >>> omarchy-hyprland >>>
export OMARCHY_PATH="$HOME/.local/share/omarchy"
export PATH="$HOME/.local/bin:$OMARCHY_PATH/bin:$PATH"
# <<< omarchy-hyprland <<<
EOF
  info "Added OMARCHY_PATH and PATH to $rc_file"
}

[[ -f "$HOME/.bashrc" ]] || touch "$HOME/.bashrc"
append_env_block "$HOME/.bashrc"
[[ -f "$HOME/.zshrc" ]] && append_env_block "$HOME/.zshrc"

# 3. Export for current process
export OMARCHY_PATH="$HOME/.local/share/omarchy"
export PATH="$HOME/.local/bin:$OMARCHY_PATH/bin:$PATH"

# 4. Mark first-run done so Omarchy doesn't trigger ISO provisioning prompts
mkdir -p "$HOME/.local/state/omarchy/done"
touch "$HOME/.local/state/omarchy/done/first-run-user"

# 5. Ensure an active theme is set (default: nord, fallback: black-sand)
STATE_THEME_DIR="$HOME/.local/state/omarchy/current/theme"
if [[ ! -d "$STATE_THEME_DIR" ]]; then
  if command -v omarchy-theme-set >/dev/null 2>&1; then
    omarchy-theme-set nord >/dev/null 2>&1 || omarchy-theme-set black-sand >/dev/null 2>&1 || true
  fi
  if [[ ! -d "$STATE_THEME_DIR" && -d "$OMARCHY_PATH/themes/nord" ]]; then
    mkdir -p "$HOME/.local/state/omarchy/current"
    cp -a "$OMARCHY_PATH/themes/nord" "$STATE_THEME_DIR"
    printf 'nord\n' > "$HOME/.local/state/omarchy/current/theme.name"
    bg=$(find "$STATE_THEME_DIR/backgrounds" -maxdepth 1 -type f | sort | head -n1 || true)
    [[ -n "$bg" ]] && ln -sf "$bg" "$HOME/.local/state/omarchy/current/background"
  fi
  info "Initialized active theme state."
fi

# 6. Reload Hyprland & Quickshell if running inside a live Hyprland session
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null 2>&1; then
  info "Live Hyprland session detected — reloading Hyprland and Omarchy shell..."
  hyprctl reload >/dev/null 2>&1 || warn "hyprctl reload failed."
  if command -v omarchy-restart-shell >/dev/null 2>&1; then
    omarchy-restart-shell >/dev/null 2>&1 || true
  fi
fi
