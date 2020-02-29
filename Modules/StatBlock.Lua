local block = {}

function block.newStatBlock(options)
    local value = options.value or 0
    local label = options.label or "Label"
    local size = options.size or 0.5
    local x = options.x or 100
    local y = options.y or 100
    local font = options.font or native.systemFont
    local group = display.newGroup()
    local innerGroup = display.newGroup()

    local frameOffset = 8

    local frame = display.newImage("Images/UI/SquareContainer.png")
    frame.anchorX, frame.anchorY = 0, 0
    frame.actualWidth = frame.width * size
    frame.actualHeight = frame.height * size
    frame: scale(size, size)

    local labelText = display.newText(label, frame.x, frame.y, font)
    labelText.anchorX, labelText.anchorY = 0, 0
    labelText.size = labelText.height * size
    centerXWidget(labelText, frame)

    local valueText = display.newText(value, labelText.x, labelText.y, font)
    valueText.size = valueText.height * size
    valueText.anchorX, valueText.anchorY = 0, 0
    centerXWidget(valueText, frame)

    innerGroup:insert(labelText)
    innerGroup:insert(valueText)
    createYOffset(innerGroup, frame, frame.y + frame.actualHeight / 2)

    centerYWidget(innerGroup, frame)

    group:insert(frame)
    group:insert(innerGroup)

    function group.updateValue(value)
        valueText.text = value
        valueText.size = valueText.height * size
        centerXWidget(valueText, frame)
    end

    function group.updateLabel(label)
        labelText.text = label
        labelText.size = labelText.height * size
        centerXWidget(labelText, frame)
    end

    return group
end

function centerXWidget(widget, frame)
    widget.x = frame.x + frame.actualWidth / 2 - widget.width / 2
end

function centerYWidget(widget, frame)
    widget.y = widget.y + frame.actualHeight / 2 - widget.height / 2
end

function createYOffset(group, frame, value)
    local anchorWidget = group[2]
    anchorWidget.y = value
end

return block