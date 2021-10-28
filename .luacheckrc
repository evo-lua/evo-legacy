std = "lua51"
max_line_length = false
exclude_files = {
	".luacheckrc",
	".evo"
}
ignore = {
	"142", -- setting undefined field ... of global ... (working as intended)
	"143", -- accessing undefined field ... of global ... (it's not undefined now, is it?)
	"212", -- unused argument (I'd rather it's obvious what arguments are passed even if they aren't currently used)
	"213", -- unused loop argument (readability improvement; _ adds nothing and is less explicit)
}
globals = {

	-- Builtins
	--- Luvi
	"args",

	-- evo-luvi
	"dump",
	"path",
	"import",

	-- evo
	-- Builtins
	"event",
	"format",
	"json",
	"log",
	"printf",
	"serialize",
	--- API
	"C_FileSystem",

	-- Shared constants
	"EVO_VERSION_MAJOR",
	"EVO_VERSION_MINOR",
	"EVO_VERSION_PATCH",
	"EVO_VERSION_STRING",
}
