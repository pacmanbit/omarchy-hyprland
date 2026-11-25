-- Hyprland bootstrap for Omarchy's Lua module path.

local home = os.getenv("HOME")
local reload_prefixes = {
  "default.hypr",
  "hypr",
  "omarchy.current.theme",
}

local function should_reload_module(module)
  for _, prefix in ipairs(reload_prefixes) do
    if module == prefix or module:sub(1, #prefix + 1) == prefix .. "." then
      return true
    end
  end

  return false
end

local modules_to_reload = {}
for module in pairs(package.loaded) do
  if should_reload_module(module) then
    table.insert(modules_to_reload, module)
  end
end

for _, module in ipairs(modules_to_reload) do
  package.loaded[module] = nil
end

local default_omarchy_path = "/usr/share/omarchy"
local bf = io.open(default_omarchy_path .. "/default/hypr/bootstrap.lua", "r")
if bf then
  bf:close()
else
  default_omarchy_path = home .. "/.local/share/omarchy"
end
local omarchy_base = os.getenv("OMARCHY_PATH") or default_omarchy_path

-- Load generated state from ~/.local/state, user modules from ~/.config, and
-- Omarchy defaults from $OMARCHY_PATH.
package.path = home
  .. "/.local/state/?.lua;"
  .. home
  .. "/.config/?.lua;"
  .. omarchy_base
  .. "/?.lua;"
  .. package.path
