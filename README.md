# Omarchy + Hyprland Portable Setup

A self-contained, portable **Omarchy 4.0 + Hyprland** desktop configuration that works on **standard Arch Linux** and **other Linux distributions** — without requiring the Omarchy OS ISO.

Includes:
- **User-space Omarchy 4.0 runtime** (`~/.local/share/omarchy` + `~/.local/bin/omarchy*`) with Quickshell bar, wallpaper daemon, lockscreen, idle manager, OSD, and menu system.
- **Hyprland Lua configuration** (`~/.config/hypr/*.lua` for Hyprland `>= 0.54`, tested on `0.57.2`).
- **Custom Top Bar & Widgets**:
  - **System Stats widget** (`CPU %` & `RAM %`).
  - **Centered bar layout** (`omarchy.indicators` + `omarchy.clock` + `omarchy.weather`).
  - **Patched `Bar.qml`** supporting custom JSON `"color"` / `"foreground"` / `"class"` (`now`, `close`) in command widgets.
  - **Optional Add-on**: [Islamic Prayer Times plugin](https://github.com/pacmanbit/omarchy-prayer-times) (not installed by default; enable via `./install.sh --with-prayer` or `omarchy plugin add`).
- **Two Themes Ready Out of the Box**: `nord` (default active) and `black-sand`.
- **Custom Keybindings**:
  - `SUPER + F` → Full width / Maximize (`maximized`)
  - `SUPER + ALT + F` → Full screen (`fullscreen`)
  - `SUPER + CTRL + F` → Tiled full screen
  - `SUPER + SHIFT + H` / `SUPER + F12` → Toggle HDR on focused monitor (`omarchy-toggle-hdr`)
  - `Left Alt + Right Alt` → Toggle keyboard layout (`us` / `ara`)
  - `SUPER + E` / `SUPER + SHIFT + F` → File Manager
  - `SUPER + RETURN` → Terminal (`kitty`)
  - `SUPER + SPACE` → Omarchy Menu / Rofi launcher
  - `SUPER + R` → App Launcher (`rofi`)

  See **[KEYBINDS.md](KEYBINDS.md)** for the full keybindings reference.

---

## Quick Install (Both Fresh & Existing Systems)

```bash
git clone https://github.com/pacmanbit/omarchy-hyprland.git ~/Projects/omarchy-hyprland
cd ~/Projects/omarchy-hyprland
chmod +x install.sh uninstall.sh scripts/*.sh
./install.sh
```

The installer automatically asks whether you want **Fresh Install** or **Existing System**, or you can pass flags directly:

### 1. Fresh Arch Linux / Minimal Install
Installs dependencies (`hyprland`, `quickshell`, `kitty`, `rofi`, `grim`, `slurp`, `wl-clipboard`, `qt6-imageformats`, Nerd Fonts, etc.), installs the Omarchy user-space runtime + configs, updates shell `PATH`/`OMARCHY_PATH`, and activates the `nord` theme:

```bash
./install.sh --fresh
```

### 2. Existing Hyprland Setup (Safe Backup + Selective Merge)
Automatically backs up your existing `~/.config/hypr`, `~/.config/omarchy`, `~/.config/kitty/kitty.conf`, `~/.config/gtk-3.0/settings.ini`, and `~/.local/share/omarchy` into `~/.local/state/omarchy-hyprland-backups/<timestamp>/`, and lets you keep your current monitors/input/terminal if you want:

```bash
./install.sh --existing
```

Non-interactive example keeping your existing monitors and input layout:

```bash
./install.sh --existing -y --keep-monitors --keep-input
```

### 3. Keybinds-Only Install (No Bar / Theme Changes)
If you only want the Hyprland keybindings (works on both **Omarchy Lua** `bindings.lua` and **standard `hyprland.conf`**):

```bash
./scripts/install-keybinds.sh
```

See [KEYBINDS.md](KEYBINDS.md) for `--lua`, `--conf`, and `--uninstall` options.

---

## Other Linux Distributions (Fedora, Debian/Ubuntu, Void, openSUSE, Nix)

Because the entire Omarchy shell and CLI run in `$HOME/.local/` without requiring the Omarchy ISO, this setup works on **any Linux distribution** that has:
1. **Hyprland >= 0.54** (with Lua config support — tested on `0.57.2`)
2. **Quickshell** (`quickshell` + `qt6-imageformats` for WebP/PNG wallpapers)
3. Standard Wayland utilities (`kitty`, `python3`, `jq`, `curl`, `libnotify`, `grim`, `slurp`, `wl-clipboard`, `rofi`, `udiskie`)

`scripts/deps.sh` automatically detects `pacman` (`yay`/`paru`), `dnf`, `apt`, `xbps-install`, and `zypper`.
On non-systemd distros (Void, Artix, Alpine), `omarchy-launch-shell` automatically falls back from `systemd-cat` to logging in `~/.local/state/omarchy/shell.log`.

---

## Customization

### Optional: Islamic Prayer Times Widget
Islamic Prayer Times is **not installed by default**. To include it during setup:

```bash
./install.sh --with-prayer --prayer-city "Al-Karak" --prayer-country "Jordan" --prayer-method "JORDAN"
```

Or install it anytime later with:

```bash
omarchy plugin add https://github.com/pacmanbit/omarchy-prayer-times.git --enable --yes
```

### Monitors & Dual-Monitor HDR Preset
By default, `config/hypr/monitors.lua` uses universal auto-detection (`preferred`, `auto`, `scale = 1`).
If you want the included dual-monitor setup (`DP-1` 2560x1440@180Hz 10-bit + rotated `HDMI-A-1` 1920x1080@60Hz), run `./install.sh --dual-monitors` or copy `config/hypr/monitors.dual-hdr.example.lua` to `~/.config/hypr/monitors.lua`.

### Switching Themes
```bash
omarchy theme list
omarchy theme set black-sand
omarchy theme set nord
```

---

## Uninstall / Restore Backup

To restore your pre-install configs from the latest backup:

```bash
./uninstall.sh
```
