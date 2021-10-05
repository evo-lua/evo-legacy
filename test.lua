-- Test path implementation
local path = require("./Core/Environment/path")
p(path)

-- Type errors: Only strings are valid paths(* excluding optional args)
local invalidTypeValues = {true, false, 7, nil, {}, 42.0}

local function fail(func, ...)
    local result, errorMessage = func(...)
    -- invalid types return nil and error
    assert(result == nil, "result is not nil")
    assert(type(errorMessage) == "string", "message is not a string")
    assert(type(errorMessage) == "string", "message is not Usage: ...") -- todo
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
    end
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
assert(path.win32.sep == '\\');
--  posix
assert.strictEqual(path.posix.sep, '/');

-- path.delimiter tests
-- windows
assert.strictEqual(path.win32.delimiter, ';');
-- posix
assert.strictEqual(path.posix.delimiter, ':');

if (ffi.os == "Windows") then
    assert(path == path.win32, "path is not using path.win32");
else
    assert(path == path.posix, "path is not using path.posix"); -- will this even work or do we have to do deep table comparisons?
end
