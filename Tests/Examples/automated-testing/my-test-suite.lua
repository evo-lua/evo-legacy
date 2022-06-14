-- Whatever name or description you set here will be displayed in the final report
local testSuite = TestSuite:Construct("Basic demonstration")

local listOfScenarioFilesToLoad = {
	"./example-scenario.lua",
	"./async-test-with-coroutines.lua"
}

testSuite:AddScenarios(listOfScenarioFilesToLoad)

-- Return test suite instance as a Lua module
return testSuite