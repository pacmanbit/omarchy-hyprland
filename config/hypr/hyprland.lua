-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

local home = os.getenv("HOME")
local omarchy_dir = os.getenv("OMARCHY_PATH")
if not omarchy_dir or omarchy_dir == "" then
  local f = io.open("/usr/share/omarchy/default/hypr/bootstrap.lua", "r")
  if f then
    f:close()
    omarchy_dir = "/usr/share/omarchy"
  else
    omarchy_dir = home .. "/.local/share/omarchy"
  end
end

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile(omarchy_dir .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })
