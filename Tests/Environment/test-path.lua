-- Upvalues
local assert = assert
local type = type
local tostring = tostring
local pairs = pairs
local dofile = dofile
local require = require

local ffi = require("ffi")

-- Tests for the path library implementation (ported from NodeJS)
_G.path = dofile("Core/Environment/path.lua") -- Expose to simulate the evo runtime environment

-- Basic smoke tests
assert(type(path.win32) == "table", "win32 path library must exist")
assert(type(path.posix) == "table", "posix path library must exist")

-- Default to the detected OS convention
if ffi.os == "Windows" then
	assert(path.convention == "Windows", "Should default to Windows path library on Windows systems")
	assert(path == path.win32, "The Path API must be using path.win32 on Windows")
else
	assert(path.convention == "POSIX", "Should default to POSIX path library on non-Windows systems")
	-- TBD: Will this even work or do we have to do deep table comparisons?
	assert(path == path.posix, "The Path API must be using path.posix on POSIX-compliant platforms")
end

-- Type errors: Only strings are valid paths(* excluding optional args)
local invalidTypeValues = {true, false, 7, nil, {}, 42.0}

local function fail(func, ...)
    local result, errorMessage = func(...)
    -- invalid types should return nil and error (Lua style), not errors (JavaScript style)
    assert(result == nil, "result is not nil")
    assert(type(errorMessage) == "string", "message is not a string: " .. tostring(errorMessage))
    assert(errorMessage:find("Usage: "), "message is not Usage: ..., actual: " .. tostring(errorMessage))
end

local functionsToTest = {
	"join",
	"resolve",
	"normalize",
	"isAbsolute",
	"relative",
	"dirname",
	"basename",
	"extname",
}

for key, value in pairs(invalidTypeValues) do

    for name, namespace in pairs( { win32 = path.win32, posix = path.posix}) do
		for index, func in ipairs(functionsToTest) do
			print("Basic input validation test: " .. name .. "." .. func .. " (input: " .. tostring(value) .. ")")
			fail(namespace[func], value)
		end

		-- These don't really fit the pattern, so just add them manually
		fail(namespace.relative, value, 'foo')
        fail(namespace.relative, 'foo', value)

		print("Completed basic input validation tests for namespace: " .. name)

    end
end


-- Path separators and delimiters should be consistent with the respective OS' convention
assert(path.win32.separator == '\\', "Windows path separator must be BACKSLASH")
assert(path.posix.separator == '/', "POSIX path separator must be FORWARD_SLASH")
assert(path.win32.delimiter, ' ', "Windows path delimiter must be SEMICOLON")
assert(path.posix.delimiter, ':', "POSIX path delimiter must be COLON")

dofile("Tests/Environment/test-path-dirname.lua")
dofile("Tests/Environment/test-path-basename.lua")
dofile("Tests/Environment/test-path-isabsolute.lua")
dofile("Tests/Environment/test-path-normalize.lua")
dofile("Tests/Environment/test-path-extname.lua")
dofile("Tests/Environment/test-path-resolve.lua")
dofile("Tests/Environment/test-path-join.lua")
dofile("Tests/Environment/test-path-relative.lua")
