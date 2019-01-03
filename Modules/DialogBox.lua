local dialog = {}

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local width = display.contentWidth
local height = display.contentHeight


function dialog.create(options)
   local dialogBox = {
       dialogGroup = display.newGroup()
   }
   local dialogGroup = dialogBox.dialogGroup
   local ops = options or {}
   local xpos = ops.xpos or centerX
   local ypos = ops.ypos or centerY
   local bodyWidth, bodyHeight = ops.width or width/2, ops.height or height/4
   local headerHeight = ops.headerHeight or bodyHeight/5

   local bodyColor = ops.bodyColor or {0.92, 0.92, 0.92}
   local headerColor = ops.headerColor or {0.42, 0.65, 0.80}

   local dialogTitle = ops.title or "Dialog Title"
   local dialogTitleColor = ops.titleColor or {1, 1, 1}

   local dialogBody = ops.bodyText or "Body Message Goes Here..."
   local dialogBodySize = ops.bodySize or 10
   local dialogBodyColor = ops.bodyTextColor or {0, 0, 0}

   local body = display.newRect(xpos, ypos, bodyWidth, bodyHeight)
   body: setFillColor(unpack(bodyColor))
   body.alpha = 0

   local headFrame = display.newRect(body.x, body.y - body.height/2, body.width, headerHeight)
   headFrame.y = headFrame.y - headFrame.height/2
   headFrame: setFillColor(unpack(headerColor))
   headFrame.alpha = 0

   local titleText = display.newText(dialogTitle, headFrame.x - headFrame.width/2, headFrame.y, headFrame.width - 5, 0, "./Fonts/Carbon-Phyber", headFrame.height - 10)
   titleText.x = titleText.x + titleText.width/2 + 5
   titleText: setFillColor(unpack(dialogTitleColor))
   titleText.alpha = 0

   local bodyText = display.newText(dialogBody, body.x - body.width/2, body.y - body.width/2, body.width - 5, body.height - 5, "./Fonts/Carbon-Phyber", dialogBodySize)
   bodyText.x = bodyText.x + bodyText.width/2 + 5
   bodyText.y = bodyText.y + bodyText.height/2 + 25
   bodyText: setFillColor(dialogBodyColor)
   bodyText.alpha = 0


   dialogGroup: insert(headFrame)
   dialogGroup: insert(body)
   dialogGroup: insert(titleText)
   dialogGroup: insert(bodyText)


   return dialogBox
end
return dialog