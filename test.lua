-- Test path implementation
local path = require("./Core/Environment/path")
-- p(path)

-- Type errors: Only strings are valid paths(* excluding optional args)
local invalidTypeValues = {true, false, 7, nil, {}, 42.0}

local function fail(func, ...)
	-- print(func, ...)
    local result, errorMessage = func(...)
    -- invalid types return nil and error
    assert(result == nil, "result is not nil")
    assert(type(errorMessage) == "string", "message is not a string: " .. tostring(errorMessage))
    assert(errorMessage:find("Usage: "), "message is not Usage: ..., actual: " .. tostring(errorMessage)) -- todo
end

for key, value in pairs(invalidTypeValues) do

    for k, namespace in pairs({path.win32, path.posix}) do
        fail(namespace.join, value);
        fail(namespace.resolve, value);
        fail(namespace.normalize, value);
        fail(namespace.isAbsolute, value);
        fail(namespace.relative, test, 'foo');
        fail(namespace.relative, 'foo', value);
        fail(namespace.parse, value);
        fail(namespace.dirname, value);
        fail(namespace.basename, value);
        fail(namespace.extname, value);
		print("Namespace tested")
    end
	print("Value tested: " .. tostring(value))
end

-- typeErrorTests.forEach((test) => {
--   [path.posix, path.win32].forEach((namespace) => {
--     fail(namespace.join, test);
--     fail(namespace.resolve, test);
--     fail(namespace.normalize, test);
--     fail(namespace.isAbsolute, test);
--     fail(namespace.relative, test, 'foo');
--     fail(namespace.relative, 'foo', test);
--     fail(namespace.parse, test);
--     fail(namespace.dirname, test);
--     fail(namespace.basename, test);
--     fail(namespace.extname, test);

--     // Undefined is a valid value as the second argument to basename
--     if (test !== undefined) {
--       fail(namespace.basename, 'foo', test);
--     }
--   });
-- });

-- path.sep tests
-- windows
assert(path.win32.sep == '\\', "Windows path separator must be BACKSLASH");
--  posix
assert(path.posix.sep == '/', "POSIX path separator must be FORWARD_SLASH");

-- path.delimiter tests
-- windows
assert(path.win32.delimiter, ';', "Windows path delimiter must be SEMICOLON");
-- posix
assert(path.posix.delimiter, ':', "POSIX path delimiter must be COLON");

local ffi = require("ffi")
if (ffi.os == "Windows") then
    assert(path == path.win32, "Path API must be using path.win32 on Windows");
else
    assert(path == path.posix, "The Path API must be using path.posix on POSIX-compliant platforms"); -- will this even work or do we have to do deep table comparisons?
end


-- win32 tests

require("./Tests/Environment/test-path-dirname.lua")

-- posix tests