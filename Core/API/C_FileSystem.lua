local fs = require("fs")

local FILE_DESCRIPTOR_TYPE_DIRECTORY = "directory"
local FILE_DESCRIPTOR_TYPE_FILE = "file"

local C_FileSystem = {}

function C_FileSystem.CreateDirectory(path)
	return fs.mkdirp(path)
end

function C_FileSystem.Exists(path)
	return fs.access(path, "R")
end

function C_FileSystem.IsFile(path)
	local fileAttributes = fs.stat(path)
	if not fileAttributes then return false end

	return fileAttributes.type == FILE_DESCRIPTOR_TYPE_FILE
end

function C_FileSystem.IsDirectory(path)
	local fileAttributes = fs.stat(path)
	if not fileAttributes then return false end

	return fileAttributes.type == FILE_DESCRIPTOR_TYPE_DIRECTORY
end

function C_FileSystem.Delete(path)
	if not C_FileSystem.Exists(path) then return false end

	if C_FileSystem.IsDirectory(path) then
		return fs.rmrf(path)
	end

	return fs.unlink(path)
end

function C_FileSystem.ReadFile(path)
	return fs.readFile(path)
end

function C_FileSystem.ScanDirectory(path)
	local directoryIterator = fs.scandir(path)

	if not directoryIterator then return end

	local directoryContents = {}
	for directoryItemInfo in directoryIterator do
		local name = directoryItemInfo.name
		local type = directoryItemInfo.type

		-- Introducing a "directory" flag will be useful to implement Walk(), or for users to query the type directly
		local canWalkRecursively = (type == FILE_DESCRIPTOR_TYPE_DIRECTORY)
		directoryContents[name] = canWalkRecursively
	end

	return directoryContents
end

function C_FileSystem.WriteFile(path, data)
	-- Always make parent directories, as that's more convenient
	return fs.writeFile(path, data, true)
end

_G.C_FileSystem = C_FileSystem