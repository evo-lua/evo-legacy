
assert(type(socket) == "table", "The socket builtin should be exported")

local exportedApiSurface = {
	"create",
	"bind",
	"close",
	"destroy",
	"connect", -- async
	"send", -- write
	"receive", -- read
	"drain",
	"pause",
	"resume",
	"reset",
	"status",
}

for index, functionName in pairs(exportedApiSurface) do
	assert(type(socket[functionName]) == "function", format("Should export function %s()", functionName))
end

-- Since the socket primitive mostly is a 1:1 mapping to libuv streams and tcp handles, we can probably get away with only testing the surface here
-- invalid,no parameters, parameters of the wrong type
-- calling functions without initializing the socket
-- high-level end-to-end tests

print("OK\tBuiltins\tsocket")