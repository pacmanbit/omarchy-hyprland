# Hyprland Keybindings Reference

Complete reference for all keybindings in **omarchy-hyprland** (custom overrides in [`config/hypr/bindings.lua`](config/hypr/bindings.lua) + Omarchy defaults).

Want **only** the keybindings without installing the full Omarchy desktop?
See [Keybinds-Only Installation](#keybinds-only-installation) below or run `./scripts/install-keybinds.sh`.

---

## Custom Overrides (`config/hypr/bindings.lua`)

| Keybind | Action | Notes |
| :--- | :--- | :--- |
| `SUPER + F` | Full width (Maximize) | Keeps top bar & gaps visible (`maximized`) |
| `SUPER + ALT + F` | Full screen | True fullscreen (`fullscreen`) |
| `SUPER + CTRL + F` | Tiled full screen | App thinks it's fullscreen while staying tiled |
| `SUPER + RETURN` | Terminal | `omarchy-launch-terminal \|\| kitty` |
| `SUPER + SPACE` | Application Menu | Omarchy menu / `rofi -show drun` / `hyprlauncher` |
| `SUPER + R` | Application Launcher | `rofi -show drun \|\| hyprlauncher` |
| `SUPER + SHIFT + RETURN` / `SUPER + SHIFT + B` | Browser | `omarchy-launch-browser` (Zen / Chromium / Firefox) |
| `SUPER + E` | File Manager | `nautilus \|\| dolphin \|\| thunar` |
| `SUPER + SHIFT + F` | File Manager | `omarchy-launch-nautilus \|\| nautilus \|\| dolphin \|\| thunar` |
| `SUPER + SHIFT + H` / `SUPER + F12` | Toggle HDR (Gaming) | Runs `omarchy-toggle-hdr` on focused monitor |
| `Left Alt + Right Alt` | Switch Keyboard Layout | Configured in `input.lua` (`us` ↔ `ara`) |

---

## Window Management & Tiling

| Keybind | Action |
| :--- | :--- |
| `SUPER + W` | Close focused window |
| `CTRL + ALT + DELETE` | Close all windows |
| `SUPER + T` | Toggle floating / tiling |
| `SUPER + J` | Toggle split orientation |
| `SUPER + P` | Pseudo-tile window |
| `SUPER + O` | Pop window out (float & pin) |
| `SUPER + L` | Toggle workspace layout |
| `SUPER + Home` | Restore saved window width |
| `SUPER + ALT + Home` | Save window width |
| `SUPER + Left Mouse Drag` | Move window |
| `SUPER + Right Mouse Drag` | Resize window |

---

## Focus, Movement & Workspaces

| Keybind | Action |
| :--- | :--- |
| `SUPER + Arrow Keys` | Focus window left / right / up / down |
| `SUPER + SHIFT + Arrow Keys` | Swap window left / right / up / down |
| `SUPER + 1..0` | Switch to workspace 1–10 |
| `SUPER + SHIFT + 1..0` | Move window to workspace 1–10 |
| `SUPER + SHIFT + ALT + 1..0` | Move window silently to workspace 1–10 |
| `SUPER + TAB` / `SUPER + SHIFT + TAB` | Next / previous workspace |
| `SUPER + CTRL + TAB` | Former workspace |
| `SUPER + Mouse Scroll` | Scroll workspaces forward / backward |
| `SUPER + S` | Toggle scratchpad |
| `SUPER + ALT + S` | Move window to scratchpad |
| `SUPER + SHIFT + ALT + Arrow Keys` | Move workspace to another monitor |
| `CTRL + ALT + TAB` / `CTRL + ALT + SHIFT + TAB` | Focus next / previous monitor |
| `ALT + TAB` / `ALT + SHIFT + TAB` | Cycle windows |

---

## Window Resizing & Tabbed Groups

| Keybind | Action |
| :--- | :--- |
| `SUPER + -` / `SUPER + =` | Resize width (`-100` / `+100`) |
| `SUPER + SHIFT + -` / `SUPER + SHIFT + =` | Resize height (`-100` / `+100`) |
| `SUPER + ALT + -` / `=` (+ `SHIFT`) | Fine resize (`25px` step) |
| `SUPER + CTRL + -` / `=` (+ `SHIFT`) | Coarse resize (`300px` step) |
| `SUPER + G` | Toggle window grouping (tabs) |
| `SUPER + ALT + G` | Remove window from group |
| `SUPER + ALT + Arrow Keys` | Move window into group direction |
| `SUPER + ALT + TAB` / `SUPER + ALT + SHIFT + TAB` | Next / previous window in group |
| `SUPER + CTRL + Left` / `Right` | Focus previous / next window in group |
| `SUPER + ALT + 1..5` | Switch to group tab 1–5 |

---

## Clipboard & Applications

| Keybind | Action |
| :--- | :--- |
| `SUPER + C` | Universal copy (`CTRL+Insert` in terminals, `CTRL+C` elsewhere) |
| `SUPER + V` | Universal paste (`SHIFT+Insert` in terminals, `CTRL+V` elsewhere) |
| `SUPER + X` | Universal cut |
| `SUPER + CTRL + V` | Clipboard history manager |
| `SUPER + SHIFT + ALT + F` | File manager in current working directory |
| `SUPER + SHIFT + ALT + B` | Private browser window |
| `SUPER + SHIFT + N` | Default editor |
| `SUPER + CTRL + T` | System monitor (`btop`) |
| `SUPER + CTRL + Q` / `XF86Calculator` | Calculator |

---

## Menus, Bar Panels & Visuals

| Keybind | Action |
| :--- | :--- |
| `SUPER + K` | Interactive keybindings viewer |
| `SUPER + ALT + SPACE` | Apps menu |
| `SUPER + ESCAPE` / `XF86PowerOff` | System power menu |
| `SUPER + CTRL + SPACE` | Wallpaper switcher |
| `SUPER + SHIFT + CTRL + SPACE` | Theme switcher |
| `SUPER + SHIFT + SPACE` | Toggle top bar visibility |
| `SUPER + BACKSPACE` | Toggle window transparency |
| `SUPER + SHIFT + BACKSPACE` | Toggle window gaps |
| `SUPER + CTRL + BACKSPACE` | Toggle single-window square aspect |
| `SUPER + CTRL + A / B / D / W / P` | Toggle Audio / Bluetooth / Display / Network / Power panel |
| `SUPER + CTRL + ALT + D` | Toggle Calendar / Clock panel |
| `SUPER + CTRL + E` | Emoji picker |
| `SUPER + CTRL + Z` / `SUPER + CTRL + ALT + Z` | Cursor zoom in / reset |
| `SUPER + CTRL + L` | Lock screen |
| `SUPER + SLASH` / `SUPER + ALT + SLASH` | Monitor scaling up / down |

---

## Screenshots, Notifications & Media

| Keybind | Action |
| :--- | :--- |
| `PRINT` | Screenshot |
| `ALT + PRINT` | Screen recording toggle / menu |
| `SUPER + PRINT` | Color picker (`hyprpicker -a`) |
| `SUPER + CTRL + PRINT` | OCR text extraction from screenshot |
| `SUPER + ,` / `SUPER + SHIFT + ,` | Dismiss one / all notifications |
| `SUPER + ALT + ,` / `SUPER + SHIFT + ALT + ,` | Invoke last / open notification history |
| `SUPER + CTRL + ,` | Toggle Do Not Disturb |
| `SUPER + CTRL + I` / `SUPER + CTRL + N` | Toggle idle lock / nightlight |
| `XF86AudioRaiseVolume` / `LowerVolume` / `Mute` | Volume controls (+ `ALT` for 1% precision) |
| `XF86AudioMicMute` | Mute microphone |
| `XF86MonBrightnessUp` / `Down` | Display brightness (+ `ALT` for 1% precision, `SHIFT` for min/max) |
| `XF86AudioPlay` / `Next` / `Prev` | Media playback controls |

---

## Keybinds-Only Installation

If you **only** want the keybindings (without replacing your bar, shell, or theme):

```bash
git clone https://github.com/pacmanbit/omarchy-hyprland.git ~/Projects/omarchy-hyprland
cd ~/Projects/omarchy-hyprland
./scripts/install-keybinds.sh
```

The script auto-detects your Hyprland config format:
- **Omarchy / Lua Hyprland (`~/.config/hypr/hyprland.lua`)**: installs `config/hypr/bindings.lua` + `omarchy-toggle-hdr` and reloads Hyprland.
- **Standard Hyprland (`~/.config/hypr/hyprland.conf`)**: installs [`config/hypr/keybinds-standalone.conf`](config/hypr/keybinds-standalone.conf) as `~/.config/hypr/keybinds-omarchy.conf`, sources it from `hyprland.conf`, and reloads Hyprland (no Omarchy dependencies required).

Options:
- `./scripts/install-keybinds.sh --lua` — force Lua `bindings.lua` install
- `./scripts/install-keybinds.sh --conf` — force standalone `.conf` install for `hyprland.conf`
- `./scripts/install-keybinds.sh --uninstall` — restore backup / remove sourced keybinds
