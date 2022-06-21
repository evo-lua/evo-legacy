local vfs = require("virtual_file_system")

local V8 = require("v8_string")
local StringPrototypeLastIndexOf = V8.StringPrototypeLastIndexOf

-- Since files from the VFS are imported via loadstring(chunk), the error messages will be extremely cluttered. Let's fix that...
--  Example: [string "describe("assertThrows", function()..."]:5: test
function vfs.getErrorMessage(fullErrorString)
	print("vfs.getErrorMessage", fullErrorString)

	local lastIndexOfColon = StringPrototypeLastIndexOf(fullErrorString, "%[string .*%]:%d+: ")

	if lastIndexOfColon == -1 then return fullErrorString end
	local errorMessage = string.sub(fullErrorString, lastIndexOfColon + string.len(": "))

	print("Found last colon at index ", lastIndexOfColon)
	print("Extracted error message: " .. errorMessage)

	return errorMessage
end

local errorFunction = _G.error

local function error(errorObjectOrString, level)
	errorFunction(vfs.getErrorMessage(errorObjectOrString), level)
end

_G.error = error

package.preload.virtual_file_system = vfs