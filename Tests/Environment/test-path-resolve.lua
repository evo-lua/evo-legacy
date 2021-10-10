

-- local fixtures = require('../common/fixtures');

-- local child = require('child_process');
local path = require("./Core/Environment/path")

local failures = {};
local slashPattern = "/";
local backslashPattern = "\\";

local ffi = require("ffi")
local uv = require("uv")

-- JavaScript is truly a thing of beauty...
local posixyCwd = ffi.os == "Windows" and
 (function()
    local _ = uv.cwd():gsub(path.sep, path.posix.sep);
	local posixPath = _:sub(_:find(path.posix.sep), #_);
	-- error(posixPath)
    return posixPath
 end)()
  or
  process.cwd();

local uv = require("uv")

local testCases = {
	-- win32
    -- Arguments                               result
    {{'c:/blah\\blah', 'd:/games', 'c:../a'}, 'c:\\blah\\a'},
     {{'c:/ignore', 'd:\\a/b\\c/d', '\\e.exe'}, 'd:\\e.exe'},
     {{'c:/ignore', 'c:/some/file'}, 'c:\\some\\file'},
     {{'d:/ignore', 'd:some/dir//'}, 'd:\\ignore\\some\\dir'},
     {{'.'}, uv.cwd()},
     {{'//server/share', '..', 'relative\\'}, '\\\\server\\share\\relative'},
     {{'c:/', '//'}, 'c:\\'},
     {{'c:/', '//dir'}, 'c:\\dir'},
     {{'c:/', '//server/share'}, '\\\\server\\share\\'},
     {{'c:/', '//server//share'}, '\\\\server\\share\\'},
     {{'c:/', '///some//dir'}, 'c:\\some\\dir'},
     {{'C:\\foo\\tmp.3\\', '..\\tmp.3\\cycles\\root.js'},
      'C:\\foo\\tmp.3\\cycles\\root.js'},
}
local posixTestCases = {
   -- posix
    -- Arguments                    result
    {{'/var/lib', '../', 'file/'}, '/var/file'},
     {{'/var/lib', '/../', 'file/'}, '/file'},
     {{'a/b/c/', '../../..'}, posixyCwd}, -- TBD: Use WSL-style path resolution for cwd instead?
     {{'.'}, posixyCwd},
     {{'/some/dir', '.', '/absolute/'}, '/absolute'},
     {{'/foo/tmp.3/', '../tmp.3/cycles/root.js'}, '/foo/tmp.3/cycles/root.js'},
}

for index, testCase in ipairs(posixTestCases) do
	p(testCase)
	local expected = testCase[2]
	local inputs = testCase[1]

	-- The behaviour should be identical for both Windows and POSIX systems
	-- _G.currentNamespace = "win32"
	-- local actual = path.win32.resolve(unpack(inputs))
	-- print(input, expected, actual, index, "win32")
	-- assertStrictEqual(actual, expected, index)

	_G.currentNamespace = "posix"
	print(input, expected, actual, index, "posix")
	actual = path.posix.resolve(unpack(inputs))
	assertStrictEqual(actual, expected, index)
end

-- if (common.isWindows) {
--   -- Test resolving the current Windows drive letter from a spawned process.
--   -- See https://github.com/nodejs/node/issues/7215
--   local currentDriveLetter = path.parse(process.cwd()).root.substring(0, 2);
--   local resolveFixture = fixtures.path('path-resolve.js');
--   local spawnResult = child.spawnSync(
--     process.argv{0}, {resolveFixture, currentDriveLetter});
--   local resolvedPath = spawnResult.stdout.toString().trim();
--   assertStrictEqual(resolvedPath.toLowerCase(), process.cwd().toLowerCase());
-- }

-- if (!common.isWindows) {
--   -- Test handling relative paths to be safe when process.cwd() fails.
--   process.cwd = () => '';
--   assertStrictEqual(process.cwd(), '');
--   local resolved = path.resolve();
--   local expected = '.';
--   assertStrictEqual(resolved, expected);
-- }

print("OK\ttest-path-resolve")