assert(type(transform) == "table", "The transform builtin should be exported")

local exportedApiSurface = {
	"black",
	"blackBackground",
	"bold",
	"brightRedBackground",
	"cyan",
	"gray",
	"green",
	"greenBackground",
	"red",
	"underline",
	"white",
	"whiteBackground",
	"yellow",
}

local ffi = require("ffi")

local invalidValues = {
	"", 42, {}, function() end, ffi.new("uint8_t")
}

for index, functionName in pairs(exportedApiSurface) do
	assert(type(transform[functionName]) == "function", format("Should export function %s()", functionName))

	for invalidValue in ipairs(invalidValues) do
		assert(transform[functionName](invalidValue) == nil, format("%s: Should return nil if passed invalid value (%s)", functionName, invalidValue))
	end

	-- Can't use this as a table entry, so we'll have to check it manually
	assert(transform[functionName](nil) == nil, format("%s: Should return nil if passed invalid value (%s)", functionName, nil))
end

-- Unfortunately we can't really test the behaviour of the terminal here, so this'll have to do...
print()
print(transform.bold("This text should be bold"))
print(transform.underline("This text should be underlined"))
print(transform.black("This text should be black"))
print(transform.cyan("This text should be cyan"))
print(transform.gray("This text should be gray"))
print(transform.green("This text should be green"))
print(transform.red("This text should be red"))
print(transform.white("This text should be white"))
print(transform.yellow("This text should be yellow"))
print(transform.blackBackground("This text should have a black background"))
print(transform.brightRedBackground("This text should have a bright red background"))
print(transform.greenBackground("This text should have a green background"))
print(transform.whiteBackground("This text should have a white background"))
print()

print("OK\tBuiltins\ttransform")