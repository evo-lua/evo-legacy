local testSuite = TestSuite:Construct("LLHTTP Integration")

local listOfScenarioFilesToLoad = {
    "./llhttp/http-request-parsing.lua"
}

testSuite:AddScenarios(listOfScenarioFilesToLoad)

return testSuite