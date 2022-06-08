local testSuite = TestSuite:Construct("Networking API")

local listOfScenarioFilesToLoad = {
    "./Networking/tcp-echo.lua"
}

testSuite:AddScenarios(listOfScenarioFilesToLoad)

return testSuite