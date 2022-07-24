local testCases = {
	"./Tests/Builtins/assertions/assertEquals.spec.lua",
	"./Tests/Builtins/assertions/assertFunctionCalls.spec.lua",
	"./Tests/Builtins/assertions/assertThrows.spec.lua",
	"./Tests/Builtins/typeof.spec.lua",
	"./Tests/Extensions/table.spec.lua",
	"./Tests/Extensions/uv.spec.lua",
	"./Tests/API/Networking/unit-tests.lua",
}

C_Testing.CreateUnitTestRunner(testCases)