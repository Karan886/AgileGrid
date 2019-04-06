local dialog = {}
local widget = require "widget"

-- Dialog box with a list of key value pairs
function dialog.infoList(list, options)
  local group = display.newGroup()
  local headerFrameColor = options.headerFrameColor or {0.25, 0.25, 0.25}
  local dialogBodyColor = options.dialogBodyColor or {0.8, 0.8, 0.8}
  local titleBarHeight = options.titleBarHeight or 30
  local width = options.width or 200
  local rowheight = options.rowHeight or 30
  local height = options.height or (#list * rowHeight)
  

end

return dialog