#!/usr/bin/env bash
# Cross-distro dependency checker and installer for omarchy-hyprland

set -euo pipefail

CHECK_ONLY=0
YES=0

for arg in "$@"; do
  case "$arg" in
    --check) CHECK_ONLY=1 ;;
    --yes|-y) YES=1 ;;
  esac
done

info()  { printf "\033[1;34m[deps]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[warn]\033[0m %s\n" "$*"; }
err()   { printf "\033[1;31m[err]\033[0m  %s\n" "$*" >&2; }

detect_distro() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    echo "${ID:-unknown}"
  else
    echo "unknown"
  fi
}

detect_pkg_mgr() {
  if command -v pacman >/dev/null 2>&1; then echo "pacman"
  elif command -v dnf >/dev/null 2>&1; then echo "dnf"
  elif command -v apt-get >/dev/null 2>&1; then echo "apt"
  elif command -v zypper >/dev/null 2>&1; then echo "zypper"
  elif command -v xbps-install >/dev/null 2>&1; then echo "xbps"
  elif command -v apk >/dev/null 2>&1; then echo "apk"
  elif command -v nix-env >/dev/null 2>&1; then echo "nix"
  else echo "unknown"
  fi
}

check_core_bins() {
  local missing=()
  local bins=(
    Hyprland
    hyprctl
    quickshell
    kitty
    python3
    jq
    curl
    notify-send
    grim
    slurp
    wl-copy
  )
  for b in "${bins[@]}"; do
    if ! command -v "$b" >/dev/null 2>&1; then
      missing+=("$b")
    fi
  done

  if command -v Hyprland >/dev/null 2>&1; then
    local ver
    ver=$(Hyprland --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1 || true)
    if [[ -n "$ver" ]]; then
      local major minor
      major=${ver%%.*}
      minor=${ver#*.}
      if (( major == 0 && minor < 54 )); then
        warn "Hyprland $ver detected. Omarchy Lua config (hyprland.lua) requires Hyprland >= 0.54 (tested on 0.57+)."
      fi
    fi
  fi

  if (( ${#missing[@]} > 0 )); then
    warn "Missing runtime commands: ${missing[*]}"
    return 1
  fi
  info "All core runtime commands are installed."
  return 0
}

install_arch() {
  local repo_pkgs=(
    hyprland
    hyprlang
    hyprcursor
    hyprgraphics
    hyprutils
    hyprsunset
    hyprpolkitagent
    xdg-desktop-portal-hyprland
    kitty
    python
    jq
    curl
    libnotify
    grim
    slurp
    wl-clipboard
    rofi
    qt6-imageformats
    qt6-wayland
    qt6-declarative
    qt6-svg
    pipewire
    wireplumber
    brightnessctl
    playerctl
    bluez
    bluez-utils
    networkmanager
    nautilus
    ttf-jetbrains-mono-nerd
    udiskie
  )

  local aur_pkgs=(
    quickshell
  )

  info "Installing official Arch packages via pacman..."
  if (( YES )); then
    sudo pacman -S --needed --noconfirm "${repo_pkgs[@]}"
  else
    sudo pacman -S --needed "${repo_pkgs[@]}"
  fi

  local aur_helper=""
  if command -v paru >/dev/null 2>&1; then
    aur_helper="paru"
  elif command -v yay >/dev/null 2>&1; then
    aur_helper="yay"
  fi

  if ! command -v quickshell >/dev/null 2>&1; then
    if [[ -n "$aur_helper" ]]; then
      info "Installing quickshell via $aur_helper..."
      if (( YES )); then
        "$aur_helper" -S --needed --noconfirm "${aur_pkgs[@]}" || "$aur_helper" -S --needed --noconfirm quickshell-git
      else
        "$aur_helper" -S --needed "${aur_pkgs[@]}" || "$aur_helper" -S --needed quickshell-git
      fi
    else
      warn "No AUR helper (paru/yay) found to install 'quickshell'."
      warn "Install yay/paru and run: yay -S quickshell (or quickshell-git)."
    fi
  fi
}

install_fedora() {
  info "Fedora detected. Installing available dependencies via dnf..."
  local pkgs=(
    hyprland
    kitty
    python3
    jq
    curl
    libnotify
    grim
    slurp
    wl-clipboard
    rofi-wayland
    qt6-qtimageformats
    qt6-qtwayland
    qt6-qtdeclarative
    qt6-qtsvg
    brightnessctl
    playerctl
    xdg-desktop-portal-hyprland
    udiskie
  )
  sudo dnf install -y "${pkgs[@]}" || true
  if ! command -v quickshell >/dev/null 2>&1; then
    warn "On Fedora, install quickshell from COPR (e.g. 'sudo dnf copr enable errornointernet/quickshell && sudo dnf install quickshell') or build from source: https://quickshell.outfoxxed.me/"
  fi
}

install_debian() {
  info "Debian/Ubuntu detected. Installing base packages via apt..."
  sudo apt-get update
  sudo apt-get install -y \
    kitty python3 jq curl libnotify-bin grim slurp wl-clipboard \
    rofi qt6-image-formats-plugins qt6-wayland brightnessctl playerctl udiskie || true
  warn "Debian/Ubuntu repos often ship older Hyprland or lack Quickshell."
  warn "Ensure Hyprland >= 0.54 (with Lua support) and Quickshell are installed from source / PPA / Nix."
}

install_void() {
  info "Void Linux detected. Installing base packages via xbps-install..."
  sudo xbps-install -Sy \
    hyprland kitty python3 jq curl libnotify grim slurp wl-clipboard \
    rofi qt6-imageformats qt6-wayland qt6-declarative qt6-svg brightnessctl playerctl udiskie || true
  if ! command -v quickshell >/dev/null 2>&1; then
    warn "Install quickshell from void-packages/source: https://quickshell.outfoxxed.me/"
  fi
}

install_opensuse() {
  info "openSUSE detected. Installing base packages via zypper..."
  sudo zypper install -y \
    hyprland kitty python3 jq curl libnotify-tools grim slurp wl-clipboard \
    rofi qt6-imageformats qt6-wayland brightnessctl playerctl udiskie || true
  if ! command -v quickshell >/dev/null 2>&1; then
    warn "Install quickshell via OBS or source: https://quickshell.outfoxxed.me/"
  fi
}

DISTRO=$(detect_distro)
PKG_MGR=$(detect_pkg_mgr)
info "Detected OS=$DISTRO, package manager=$PKG_MGR"

if (( CHECK_ONLY )); then
  check_core_bins || exit 1
  exit 0
fi

case "$PKG_MGR" in
  pacman) install_arch ;;
  dnf)    install_fedora ;;
  apt)    install_debian ;;
  xbps)   install_void ;;
  zypper) install_opensuse ;;
  *)
    warn "Unsupported or manual package manager ($PKG_MGR)."
    warn "Please install: hyprland (>=0.54, Lua support), quickshell, qt6-imageformats, kitty, python3, jq, curl, libnotify, grim, slurp, wl-clipboard, rofi, udiskie, Nerd Fonts."
    ;;
esac

check_core_bins || warn "Some optional/core commands are still missing; see warnings above."
