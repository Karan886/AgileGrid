local file = {}
file.location = system.DocumentsDirectory

local json = require "json"

function file.create(name, contents)
    local path = system.pathForFile(name, file.location)
    local open, errorMsg = io.open(path, "r")
    if not open then
    	--file does not exist, create one
       local open, errorMsg = io.open(path, "w")
       if open then
       	   open:write(contents)
           print("file "..name.." is successfully created")
           io.close()
           return true

       end
       print("Error: the file "..name.." could not be created, error message: "..errorMsg)
       io.close()
       return false
    end
    print("Error: the file "..name.." already exists, cannot create duplicate")
    io.close()
    return false
end

function file.save(name, contents)
    local path = system.pathForFile(name, file.location)
    local open, errorMsg = io.open(path, "w")
    if not open then
    	print("Error: saving data to file "..name.." failed. Error message: "..errorMsg)
    	io.close()
    	return false
    end
    open:write(contents)
    io.close()
    print("Saving data to file "..name.." successful")
    return true
end

function file.load(name)
	local path = system.pathForFile(name, file.location)
	local open, errorMsg = io.open(path, "r")
	if not open then
		print("Error: loading data from file "..name.." failed. Error message: "..errorMsg)
		io.close()
		return false
	end
	local contents = open:read("*a")
	io.close()
	return contents
end

function file.loadJson(filename, property)
	local path = system.pathForFile(filename, file.location)
	local decodedJson, position, msg = json.decodeFile(path)
	local returnVal = nil
	if not decodedJson then
		print("Error: could not read json file "..filename.." at position "..position.. " with error message: "..msg)
		return returnVal
	end
	if (property ~= nil) then
		returnVal = decodedJson[property]
	else
		returnVal = decodedJson
	end
	return returnVal
end 


return file