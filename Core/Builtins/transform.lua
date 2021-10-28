local transform = {}

local COLOR_START_SEQUENCE = "\27["
local RESET_SEQUENCE = "\27[0;0m"
local COLOR_CODE_BOLD = "0;1m"
local COLOR_CODE_UNDERLINE = "0;4m"
local COLOR_CODE_GREEN = "0;32m"
local COLOR_CODE_GRAY = "1;30m"
local COLOR_CODE_WHITE = "1;37m"
local COLOR_CODE_BLACK = "1;30m"
local COLOR_CODE_RED = "0;31m"
local COLOR_CODE_CYAN = "0;96m"
local COLOR_CODE_YELLOW = "0;33m"
local COLOR_CODE_RED_BACKGROUND_BRIGHT = "0;101m"
local COLOR_CODE_BLACK_BACKGROUND = "0;40m"
local COLOR_CODE_GREEN_BACKGROUND = "0;42m"
local COLOR_CODE_WHITE_BACKGROUND = "0;47m"

local type = type

function transform.bold(text)
	if type(text) ~= "string" then return nil, "Usage: bold(text)" end
	return COLOR_START_SEQUENCE .. COLOR_CODE_BOLD .. text .. RESET_SEQUENCE
end

function transform.underline(text)
	if type(text) ~= "string" then return nil, "Usage: underline(text)" end
	return COLOR_START_SEQUENCE .. COLOR_CODE_UNDERLINE .. text .. RESET_SEQUENCE
end

function transform.black(text)
	if type(text) ~= "string" then return nil, "Usage: black(text)" end
	return COLOR_START_SEQUENCE .. COLOR_CODE_BLACK .. text .. RESET_SEQUENCE
 end

function transform.blackBackground(text)
	if type(text) ~= "string" then return nil, "Usage: blackBackground(text)" end
	return COLOR_START_SEQUENCE .. COLOR_CODE_BLACK_BACKGROUND .. text .. RESET_SEQUENCE
end

function transform.green(text)
	if type(text) ~= "string" then return nil, "Usage: green(text)" end
	return COLOR_START_SEQUENCE .. COLOR_CODE_GREEN .. text .. RESET_SEQUENCE
end

function transform.gray(text)
	if type(text) ~= "string" then return nil, "Usage: gray(text)" end
	return COLOR_START_SEQUENCE .. COLOR_CODE_GRAY .. text .. RESET_SEQUENCE
end

function transform.white(text)
	if type(text) ~= "string" then return nil, "Usage: white(text)" end
	return COLOR_START_SEQUENCE .. COLOR_CODE_WHITE .. text .. RESET_SEQUENCE
end

function transform.red(text)
	if type(text) ~= "string" then return nil, "Usage: red(text)" end
	return COLOR_START_SEQUENCE .. COLOR_CODE_RED .. text .. RESET_SEQUENCE
end

function transform.cyan(text)
	if type(text) ~= "string" then return nil, "Usage: cyan(text)" end
	return COLOR_START_SEQUENCE .. COLOR_CODE_CYAN .. text .. RESET_SEQUENCE
end

function transform.yellow(text)
	if type(text) ~= "string" then return nil, "Usage: yellow(text)" end
	return COLOR_START_SEQUENCE .. COLOR_CODE_YELLOW .. text .. RESET_SEQUENCE
end

function transform.brightRedBackground(text)
	if type(text) ~= "string" then return nil, "Usage: brightRedBackground(text)" end
	return COLOR_START_SEQUENCE .. COLOR_CODE_RED_BACKGROUND_BRIGHT .. text .. RESET_SEQUENCE
end

function transform.greenBackground(text)
	if type(text) ~= "string" then return nil, "Usage: greenBackground(text)" end
	return COLOR_START_SEQUENCE .. COLOR_CODE_GREEN_BACKGROUND .. text .. RESET_SEQUENCE
end

function transform.whiteBackground(text)
	if type(text) ~= "string" then return nil, "Usage: whiteBackground(text)" end
	return COLOR_START_SEQUENCE .. COLOR_CODE_WHITE_BACKGROUND .. text .. RESET_SEQUENCE
end

_G.transform = transform