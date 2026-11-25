-- User autostart processes

hl.env("QT_PLUGIN_PATH", os.getenv("HOME") .. "/.local/lib/qt6:/usr/lib/qt6/plugins")
hl.env("LD_LIBRARY_PATH", os.getenv("HOME") .. "/.local/lib:" .. (os.getenv("LD_LIBRARY_PATH") or ""))

-- Ensure Waybar is stopped so Quickshell manages the desktop bar and background
hl.exec_cmd("killall waybar 2>/dev/null || true")

-- Start the native Omarchy desktop shell (bar, wallpaper, popups)
hl.exec_cmd("omarchy-launch-shell")
