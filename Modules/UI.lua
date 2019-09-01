local ui = {}

-- Some dimensions
--some dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth
local centerX = display.contentCenterX
local centerY = display.contentCenterY

function ui.displayGameStats(ops)
    local data = ops.data
    local layer = ops.layer
    -- Container width and Height
    local width = ops.width
    local height = ops.height
    -- Container center
    local x = ops.x
    local y = ops.y
    -- Other options (optional)
    local yOffsetFactor = ops.yOffsetFactor or 2
    local fontSize = ops.fontSize or 14
    local color = ops.color or {key = {0, 0, 0}, value = {0, 0.5, 0}}
    local font = ops.font or "Fonts/BigBook-Heavy"

    local startX = x - width / 2
    local startY = y - height / 2
    for index in pairs(data) do
        local stat = data[index] 
        local key = stat.item
        local value = stat.value
        
        if (ops.alias and ops.alias[key]) then
            key = ops.alias[key]
        end
        local keyText = display.newText(key, startX, 0, font, fontSize)
        local yOffset = keyText.height * yOffsetFactor
        keyText.y = startY + (index * yOffset)
        keyText: setFillColor(unpack(color.key))
        keyText.anchorX, keyText.anchorY = 0, 0
        layer: insert(keyText)

        local valueText = display.newText(value, startX + width, 0, font, fontSize)
        valueText.anchorX, valueText.anchorY = 1, 0
        valueText.y = keyText.y
        valueText: setFillColor(unpack(color.value))
        layer: insert(valueText)
    end
end

function ui.displaySettings(ops)
    local yStart = ops.yStart
    local xStart = ops.xStart
    local titleFont = ops.titleFont or "Fonts/BigBook-Heavy"
    local contentFont = ops.font or "Fonts/BigBook-Heavy"
    local titleSize = ops.titleSize or 13
    local contentSize = ops.fontSize or 10
    local layer = ops.layer
    local titleColor = ops.titleColor or {0, 0, 0}

    local settingsTitle = display.newText("Settings", centerX, yStart, titleFont, titleSize)
    settingsTitle.anchorY = 0
    settingsTitle: setFillColor(unpack(titleColor))
    layer: insert(settingsTitle)
end

return ui