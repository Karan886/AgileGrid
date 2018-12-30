local exception = {}
exception.warning = "WARNING"
exception.error = "ERROR"

function exception.new(kind, message)
    local errorType = kind or "ERROR"
    local printMessage = message or "kind message was not provided."
    print(errorType..": "..printMessage)
end
return exception