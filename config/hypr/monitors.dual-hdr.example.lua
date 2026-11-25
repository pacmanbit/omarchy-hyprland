-- Monitors configuration
-- Left (DP-1, MSI 1440p 180Hz) and Right (HDMI-A-1, Samsung 1080p 60Hz)

hl.env("GDK_SCALE", "1")

-- Left screen: DP-1 at 0x0 (10-bit mode, standard sRGB by default, HDR toggleable)
hl.monitor({
    output   = "DP-1",
    mode     = "2560x1440@180",
    position = "0x0",
    scale    = 1,
    bitdepth = 10,
    cm       = "srgb",
})

-- Right screen: HDMI-A-1 at 2560x0 (Inverted Vertical / 270° transform)
hl.monitor({
    output    = "HDMI-A-1",
    mode      = "1920x1080@60",
    position  = "2560x0",
    scale     = 1,
    transform = 3,
})

-- Fallback for any other connected display
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Workspace monitor bindings
-- Main screen (DP-1): Workspace 1 as default
hl.workspace_rule({
    workspace = "1",
    monitor   = "DP-1",
    default   = true,
})

-- Secondary screen (HDMI-A-1): Workspace 2 as default
hl.workspace_rule({
    workspace = "2",
    monitor   = "HDMI-A-1",
    default   = true,
})
