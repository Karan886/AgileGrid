local dialog = {}

dialog.confirmation = "CONFIRMATION"

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local width = display.contentWidth
local height = display.contentHeight

local widget = require "widget"

local alpha = 0.7


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

   local bodyColor = ops.bodyColor or {0.92, 0.92, 0.92, alpha}
   local headerColor = ops.headerColor or {0.42, 0.65, 0.80, alpha}

   local dialogTitle = ops.title or ""
   local dialogTitleColor = ops.titleColor or {1, 1, 1}

   local dialogBody = ops.bodyText or ""
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

   local bodyText = display.newText(dialogBody, body.x - body.width/2, body.y - body.height/2, body.width - 5, body.height - 5, "./Fonts/Carbon-Phyber", dialogBodySize)
   bodyText.x = bodyText.x + bodyText.width/2 + 5
   bodyText.y = bodyText.y + bodyText.height/2 + 5
   bodyText: setFillColor(dialogBodyColor)
   bodyText.alpha = 0

   dialogGroup: insert(headFrame)
   dialogGroup: insert(body)
   dialogGroup: insert(titleText)
   dialogGroup: insert(bodyText)

   if (ops.dialogType == dialog.confirmation) then
   	     local bgColor = headerColor
   	     bgColor[4] = 1.0
 
         local yesButton = widget.newButton({
             label = "YES",
             shape = "roundedRect",
             fillColor = {over = {unpack(bgColor)}, default = {unpack(bgColor)}},
             fontSize = 12,
             font = "./Fonts/Carbon-Bl",
             labelColor = {over = {1, 1, 1}, default = {1, 1, 1}},
             width = body.width/5,
             height = body.height/4,
             onPress = ops.onConfirm
         })
         yesButton.alpha = 0
         yesButton.x = body.x - body.width/2 + yesButton.width/2 + 5
         yesButton.y = body.y + body.height/2 - yesButton.height/2 - 5
         dialogGroup: insert(yesButton)

         local noButton = widget.newButton({
             label = "NO",
             shape = "roundedRect",
             fillColor = {over = {unpack(bgColor)}, default = {unpack(bgColor)}},
             fontSize = 12,
             font = "./Fonts/Carbon-Bl",
             labelColor = {over = {1, 1, 1}, default = {1, 1, 1}},
             width = body.width/5,
             height = body.height/4,
             onPress = ops.onDeny
         })
         noButton.alpha = 0
         noButton.x = yesButton.x + noButton.width + 5
         noButton.y = yesButton.y
         dialogGroup: insert(noButton)
   end
  
   dialogBox.show = function()
      for i = 1, dialogGroup.numChildren do
      	dialogGroup[i].alpha = 1.0
      end 
   end

   dialogBox.hide = function()
       for i = 1, dialogGroup.numChildren do
           dialogGroup[i].alpha = 0
       end
   end

   return dialogBox
end
return dialog