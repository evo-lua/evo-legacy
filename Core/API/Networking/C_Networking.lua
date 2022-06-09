local ffi = require("ffi")

local isWindows = (ffi.os == "Windows")

local WINDOWS_SHARED_LIBRARY_EXTENSION = "dll"
local UNIX_SHARED_LIBRARY_EXTENSION = "so"
local expectedFileExtension = isWindows and WINDOWS_SHARED_LIBRARY_EXTENSION or UNIX_SHARED_LIBRARY_EXTENSION

local llhttp = ffi.load("llhttp" .. "." .. expectedFileExtension)
package.preload["llhttp"] = function() return llhttp end
-- dump(llhttp)
---

local Socket = import("Socket.lua")
local TcpServer = import("TcpServer.lua")

local C_Networking = {}

function C_Networking.CreateTcpServer()
	return TcpServer:Construct()
end

function C_Networking.CreateSocket()
	return Socket:Construct()
end

_G.C_Networking = C_Networking