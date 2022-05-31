local numSetupExecutions = 0
local numTestExecutions = 0
local numEvaluationExecutions = 0
local numCleanupExecutions = 0

local function setupFunctionMustRunFirst()
	numSetupExecutions = numSetupExecutions + 1
end

local function testFunctionMustRunSecond()
	numTestExecutions = numTestExecutions + 1
end

local function evaluationFunctionMustRunThird()
	numEvaluationExecutions = numEvaluationExecutions + 1
end

local function cleanupFunctionMustRunLast()
	numCleanupExecutions = numCleanupExecutions + 1
end

local scenario = Scenario:Construct("Hooks are evaluated in order")

assertEquals(numSetupExecutions, 0)
assertEquals(numTestExecutions, 0)
assertEquals(numEvaluationExecutions, 0)
assertEquals(numCleanupExecutions, 0)

scenario:GIVEN("", setupFunctionMustRunFirst)
scenario:WHEN("", testFunctionMustRunSecond)
scenario:THEN("", evaluationFunctionMustRunThird)
scenario:FINALLY(cleanupFunctionMustRunLast)

assertEquals(numSetupExecutions, 0)
assertEquals(numTestExecutions, 0)
assertEquals(numEvaluationExecutions, 0)
assertEquals(numCleanupExecutions, 0)

scenario:Run()

assertEquals(numSetupExecutions, 1)
assertEquals(numTestExecutions, 1)
assertEquals(numEvaluationExecutions, 1)
assertEquals(numCleanupExecutions, 1)

scenario:Run()

assertEquals(numSetupExecutions, 2)
assertEquals(numTestExecutions, 2)
assertEquals(numEvaluationExecutions, 2)
assertEquals(numCleanupExecutions, 2)

scenario:Run()

assertEquals(numSetupExecutions, 3)
assertEquals(numTestExecutions, 3)
assertEquals(numEvaluationExecutions, 3)
assertEquals(numCleanupExecutions, 3)