-- Git status indicators in the file listing
require("git"):setup()

-- Show currently playing mpv track in the status bar
-- Reads from /tmp/mpv-yazi-current (written by mpv-yazi script)
Status:children_add(function()
  local f = io.open("/tmp/mpv-yazi-current", "r")
  if not f then return ui.Line({}) end
  local track = f:read("*l")
  f:close()
  if not track or track == "" then return ui.Line({}) end
  return ui.Line({
    ui.Span("  ▶ " .. track .. " "):style(ui.Style():fg("green")),
  })
end, 2000, Status.RIGHT)
