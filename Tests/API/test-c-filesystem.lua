
assert(type(C_FileSystem) == "table", "The C_FileSystem API should be exported")

local exportedApiSurface = {
	"CreateDirectory", -- mkdir / mkdirp
	"IsDirectory",
	"IsFile",
	"Delete",
	"ScanDirectory", -- scandir / filter, sorting order
	"ReadFile", -- readFile
	"WriteFile", -- writeFile
}

for index, functionName in pairs(exportedApiSurface) do
	assert(type(C_FileSystem[functionName]) == "function", format("Should export function %s()", functionName))
end


-- Scenario: Creating a directory, querying some basic properties, then deleting it
assert(C_FileSystem.Exists("someFolder") == false, "Exists: Should return false if the file or folder doesn't exist")
assert(C_FileSystem.IsDirectory("someFolder") == false, "IsDirectory: Should return false if there is no file or folder with that name")
assert(C_FileSystem.IsFile("someFolder") == false, "IsFile: Should return false if there is no file or folder with that name")
assert(C_FileSystem.Delete("someFolder") == false, "Delete: Should return false if there is no file or folder with that name")

assert(C_FileSystem.CreateDirectory("someFolder") == true, "CreateDirectory: Should return true after a folder has been created successfully")
assert(C_FileSystem.Exists("someFolder") == true, "Exists: Should return true if the path is a directory")
assert(C_FileSystem.IsDirectory("someFolder") == true, "IsDirectory: Should return true if the path is a directory")
assert(C_FileSystem.IsFile("someFolder") == false, "IsFile: Should return false if the path is a directory")
assert(C_FileSystem.Delete("someFolder") == true, "Delete: Should return true if the path is a directory and it was removed successfully")


-- git can't track empty directories, so the tests/CI will fail unless it is created manually
C_FileSystem.CreateDirectory(path.resolve(path.join(_G.USER_SCRIPT_ROOT, "Tests", "Fixtures", "someEmptyDirectory")))
-- Scenario: Listing the contents of an existing directory
local emptyDirectoryContents = C_FileSystem.ScanDirectory(path.resolve(path.join(_G.USER_SCRIPT_ROOT, "Tests", "Fixtures", "someEmptyDirectory")))
assert(type(emptyDirectoryContents) == "table", "ScanDirectory: Should return a table when listing the contents of an empty directory")
assert(table.count(emptyDirectoryContents) == 0, "ScanDirectory: Should return an empty table when listing the contents of an empty directory")

local almostEmptyDirectoryContents = C_FileSystem.ScanDirectory(path.resolve(path.join(_G.USER_SCRIPT_ROOT, "Tests", "Fixtures", "almostEmptyDirectory")))
assert(type(almostEmptyDirectoryContents) == "table", "ScanDirectory: Should return a table when listing the contents of an almost-empty directory")
assert(table.count(almostEmptyDirectoryContents) == 2, "ScanDirectory: Should return a table with the right number of elements when listing the contents of non-empty directory")

assert(C_FileSystem.ScanDirectory("nonexistentPath") == nil, "Should return nil when attempting to scan a directory that doesn't exit")

-- Scenario: Reading an existing file from disk, in text/read-only mode
local fileContents = C_FileSystem.ReadFile(path.resolve(path.join(_G.USER_SCRIPT_ROOT, "Tests", "Fixtures", "almostEmptyDirectory", "42.txt")))
assert(fileContents == "Hello world!", "Should be able to read file contents as text")

-- Use fully resolved, absolute paths here to be sure it will work anywhere (performance doesn't matter here)
local text = "some text"
local parentFolderPath = path.resolve(path.join(_G.USER_SCRIPT_ROOT, "Tests", "Fixtures", "newFolderThatHasToBeCreatedRecursively"))
local filePath = path.join(parentFolderPath, "newFile.txt")
assert(C_FileSystem.Exists(filePath) == false, "Should not have a file " .. filePath .. " before the test is run")
assert(C_FileSystem.WriteFile(filePath, text), "Should be able to write to a new file")
assert(C_FileSystem.ReadFile(filePath) == text, "Should be able to read the text from the file it was previously written to")
assert(C_FileSystem.Exists(filePath) == true, "Should have created a new file at " .. filePath)
assert(C_FileSystem.IsFile(filePath) == true, "Should detect " .. filePath .. " is a file")
assert(C_FileSystem.Delete(parentFolderPath), "Should be able to delete " .. parentFolderPath)
assert(C_FileSystem.Exists(filePath) == false, "Should be able to delete " .. filePath .. " by deleting the parent folder " .. parentFolderPath)

print("OK\tAPI\t\tC_FileSystem")