std = "lua51"
max_line_length = false
exclude_files = {
	".luacheckrc",
}
ignore = {
}
globals = {

	-- Builtins
	--- Luvi
	"args",

	-- evo-luvi
	"dump",
	"import",

	-- evo
	"format",
	"log",
	"printf",
	"serialize",

	-- Shared constants
	"EVO_VERSION_MAJOR",
	"EVO_VERSION_MINOR",
	"EVO_VERSION_PATCH",
	"EVO_VERSION_STRING",
}
