-- Universal default monitor configuration (works on any display / laptop / desktop)
-- See monitors.dual-hdr.example.lua for a dual-monitor + 10-bit HDR + vertical display example.

hl.env("GDK_SCALE", "1")

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})
