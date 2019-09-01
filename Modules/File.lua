local file = {}
local json = require "json"
local exception = require "Modules.Exception"

function file.create(name, contents, location)
    local path = system.pathForFile(name, location)
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
       exception.new(exception.error, "The file "..name.." could not be created, error message: "..errorMsg)
       io.close()
       return false
    end
    exception.new(exception.warning, "The file "..name.." already exists, cannot create duplicate")
    io.close()
    return false
end

function file.save(name, contents, location)
    local path = system.pathForFile(name, location)
    local open, errorMsg = io.open(path, "w")
    if not open then
      exception.new(exception.error, "Saving data to file "..name.." failed. Error message: "..errorMsg)
    	io.close()
    	return false
    end
    open:write(contents)
    io.close()
    print("Saving data to file "..name.." successful")
    return true
end

function file.load(name, location)
	local path = system.pathForFile(name, location)
	local open, errorMsg = io.open(path, "r")
	if not open then
    exception.new(exception.error, "Loading data from file "..name.." failed. "..errorMsg)
		io.close()
		return false
	end
	local contents = open:read("*a")
	io.close()
	return contents
end

function file.loadJson(filename, location, property)
	local path = system.pathForFile(filename, location)
	local decodedJson, position, msg = json.decodeFile(path)
	local returnVal = nil
	if not decodedJson then
    exception.new(exception.error, "Could not read json file "..filename.." at position "..position.. " with error message: "..msg)
		return returnVal
	end
    
	if (property ~= nil) then
		returnVal = decodedJson[property]
	else
		returnVal = decodedJson
	end
  print("successfully loaded JSON from file "..filename)
	return returnVal
end 

return file