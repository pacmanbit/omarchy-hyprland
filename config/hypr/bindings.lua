-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- Terminal fallback
hl.unbind("SUPER + RETURN")
o.bind("SUPER + RETURN", "Terminal", "omarchy-launch-terminal || kitty")

-- App Launcher / Menu
hl.unbind("SUPER + SPACE")
o.bind("SUPER + SPACE", "Application Menu", "omarchy-menu toggle root 2>/dev/null || rofi -show drun || hyprlauncher")
o.bind("SUPER + R", "Application Launcher", "rofi -show drun || hyprlauncher")

-- Browser (Zen Browser / Chromium / Firefox)
hl.unbind("SUPER + SHIFT + RETURN")
hl.unbind("SUPER + SHIFT + B")
o.bind("SUPER + SHIFT + RETURN", "Browser", "omarchy-launch-browser")
o.bind("SUPER + SHIFT + B", "Browser", "omarchy-launch-browser")

-- File Manager
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File Manager", "omarchy-launch-nautilus || nautilus || dolphin || thunar")
o.bind("SUPER + E", "File Manager", "nautilus || dolphin || thunar")

-- HDR Toggle for gaming (manual toggle instead of auto on fullscreen)
o.bind("SUPER + SHIFT + H", "Toggle HDR (Gaming)", "omarchy-toggle-hdr")
o.bind("SUPER + F12", "Toggle HDR (Gaming)", "omarchy-toggle-hdr")

-- Fullscreen / Maximize (swap SUPER+F and SUPER+ALT+F)
hl.unbind("SUPER + F")
hl.unbind("SUPER + ALT + F")
o.bind("SUPER + F", "Full width (Maximize)", hl.dsp.window.fullscreen({ mode = "maximized" }))
o.bind("SUPER + ALT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
