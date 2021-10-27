std = "lua51"
max_line_length = false
exclude_files = {
	".luacheckrc",
	".evo"
}
ignore = {
	"212", -- unused argument (I'd rather it's obvious what arguments are passed even if they aren't currently used)
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
	"format",
	"json",
	"log",
	"printf",
	"serialize",

	-- Shared constants
	"EVO_VERSION_MAJOR",
	"EVO_VERSION_MINOR",
	"EVO_VERSION_PATCH",
	"EVO_VERSION_STRING",
}
