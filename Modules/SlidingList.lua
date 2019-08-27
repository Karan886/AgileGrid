local list = {}

--some dimensions
local actualHeight = display.actualContentHeight
local actualWidth = display.actualContentWidth
local centerX = display.contentCenterX
local centerY = display.contentCenterY

function createRows(ops)
	local width = ops.width
	local height = ops.height

	local rowColor = ops.rowColor
	local x , y= ops.x, ops.y

	local viewGroup = display.newGroup()
	local data = ops.data

	local maxRows = ops.maxRows
	for i = 0, (maxRows - 1) do
		local rowBg = display.newRect(x, y + ((height + 5) * i), width, height)
		rowBg.anchorX, rowBg.anchorY = 0, 0

		rowBg: setFillColor(unpack(rowColor))
		viewGroup: insert(rowBg) 
	end

	return viewGroup
end

function list.createSlidingList(ops)
	local width = ops.width or actualWidth
	local height = ops.height or 30

	local x = ops.x or centerX
	local y = ops.y or centerY

	local rowColor = ops.color or {0.5, 0.5, 0.5, 0.7}

	local viewGroup = display.newGroup()
	local maxRows = ops.maxRows or 3

	local index = 0

	local rows = createRows({
		data = {
			objective1 = "",
			objective2 = "",
			objective3 = ""
		},
		x = x,
		y = y,
		rowColor = rowColor,
		maxRows = maxRows,
		width = width,
		height = height
	})

	viewGroup: insert(rows)
	return viewGroup
end

return list