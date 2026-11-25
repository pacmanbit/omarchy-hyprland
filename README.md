# Omarchy + Hyprland Portable Setup

A self-contained, portable **Omarchy 4.0 + Hyprland** desktop configuration that works on **standard Arch Linux** and **other Linux distributions** — without requiring the Omarchy OS ISO.

Includes:
- **User-space Omarchy 4.0 runtime** (`~/.local/share/omarchy` + `~/.local/bin/omarchy*`) with Quickshell bar, wallpaper daemon, lockscreen, idle manager, OSD, and menu system.
- **Hyprland Lua configuration** (`~/.config/hypr/*.lua` for Hyprland `>= 0.54`, tested on `0.57.2`).
- **Custom Top Bar & Widgets**:
  - **Islamic Prayer Times widget** (`~/.config/omarchy/bar/scripts/prayer-times`) with **3-state dynamic colors** (`NOW` = green `#50FA7B`, `CLOSE` within 30m = amber `#FAB387`, `FAR` = theme default), desktop Adhan notifications, bilingual EN/AR tooltip, and configurable city/country/method (defaults to **Al-Karak, Jordan** — Jordan Awqaf).
  - **System Stats widget** (`CPU %` & `RAM %`).
  - **Centered bar layout** (`omarchy.indicators` + `omarchy.clock` + `prayer-times`).
  - **Patched `Bar.qml`** supporting custom JSON `"color"` / `"foreground"` / `"class"` (`now`, `close`) in command widgets.
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

### Islamic Prayer Times City
Edit `~/.config/omarchy/prayer-times.json` (or pass `--prayer-city`, `--prayer-country`, `--prayer-method` to `./install.sh`):

```json
{
  "city": "Al-Karak",
  "country": "Jordan",
  "method": "JORDAN"
}
```
Then right-click the prayer widget on the bar to refresh immediately. To remove it completely, install with `--no-prayer`.

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
