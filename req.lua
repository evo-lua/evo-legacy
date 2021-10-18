-- local args, test = ...

local function dump(t)
	for k, v in pairs(t) do
		print(k, v)
	end
end

local debug = {}

function debug.runtime()
	return args[0] -- Does not work with PUC Lua (use ... or args instead?)
end

function debug.script()
	return args[1]
end

function debug.arguments()
	return args -- Remove runtime/script?
end

-- TODO restore varargs, pass scriptName , varargs functionality should be used for runtime/script name? (addonName, addonTable maybe even?)
-- C_System.IsWindows()
-- C_System.IsMacOS()
-- C_System.IsUnix() -- Linux/Other?
-- C_Debug.GetRuntime()
-- C_Debug.GetScriptName()
-- C_Debug.GetArguments()
-- __filename, __dirname

-- relative requires, path resolution
-- circular dependencies
-- caching
-- .evo modules
-- tests: https://github.com/luvit/luvit/blob/master/tests/test-require.lua

-- parent = nil, isMain = true
-- parent = file that loads the script??

print(debug.runtime())
print(debug.arguments())
dump(debug.arguments())

local uv = require("uv")

-- cwd = E:\GitHub\EvoLua\evo\Core
local cwd = uv.cwd()
-- script = E:\GitHub\EvoLua\evo\Core\..\main.lua
local script = cwd .. "/" .. debug.script() -- use path library for OS-agnostic separators etc?
-- scriptRoot = E:\GitHub\EvoLua\evo\
local scriptRoot = nil -- TODO tricky?
-- relativePath = Core/Environment/printf.lua
-- absolutePath = resolveRelativePath(relativePath)
-- absolutePath = E:\GitHub\EvoLua\evo\Core/Environment/printf.lua
-- printf = require("E:/GitHub/EvoLua/evo/Core/Environment/printf.lua")

print(cwd)
print(script)
-- printf("%s", "meep")

-- print(args)
-- dump(args)
-- print(arg[0])
-- print(arg[1])
-- print(arg[2])
-- print(arg[3])