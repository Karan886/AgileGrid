local stack = {}

function stack.newInstance()
	local colorStackInstance = {}

	colorStackInstance.push = function (item)
        colorStackInstance[#colorStackInstance + 1] = item
        if (#colorStackInstance > 3) then
    	     table.remove(colorStackInstance, 1)
        end
    end

    colorStackInstance.out = function () 
	     print("Printing items in the stack")
	     for i = 1, #colorStackInstance do
		     print("Item "..i.." : "..colorStackInstance[i])
	     end
    end

    colorStackInstance.contains = function(item)
        for i = 1, #colorStackInstance do
		     if (colorStackInstance[i] == item) then
		     	return true
		     end
	    end
	    return false
    end

    return colorStackInstance
end

return stack