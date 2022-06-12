local scenario = Scenario:Construct("Event handlers are called when a scenario is run")

local numSetupExecutions = 0
local numTestExecutions = 0
local numEvaluationExecutions = 0
local numCleanupExecutions = 0

scenario.someValue = 42

function scenario:OnSetup()
	numSetupExecutions = numSetupExecutions + 1
	assertEquals(self.someValue, 42, "Parameter self should be passed to OnSetup")
end

function scenario:OnRun()
	numTestExecutions = numTestExecutions + 1
	assertEquals(self.someValue, 42, "Parameter self should be passed to OnRun")
end

function scenario:OnEvaluate()
	numEvaluationExecutions = numEvaluationExecutions + 1
	assertEquals(self.someValue, 42, "Parameter self should be passed to OnEvaluate")
end

function scenario:OnCleanup()
	numCleanupExecutions = numCleanupExecutions + 1
	assertEquals(self.someValue, 42, "Parameter self should be passed to OnCleanup")
end

assertEquals(numSetupExecutions, 0, "Should not call the OnSetup handler before the scenario was run")
assertEquals(numTestExecutions, 0, "Should not call the OnRun handler before the scenario was run")
assertEquals(numEvaluationExecutions, 0, "Should not call the OnEvaluate handler before the scenario was run")
assertEquals(numCleanupExecutions, 0, "Should not call the OnCleanup handler before the scenario was run")

scenario:Run()

assertEquals(numSetupExecutions, 1, "Should call the OnSetup handler when the scenario is run")
assertEquals(numTestExecutions, 1, "Should call the OnRun handler when the scenario is run")
assertEquals(numEvaluationExecutions, 1, "Should call the OnEvaluate handler when the scenario is run")
assertEquals(numCleanupExecutions, 1, "Should call the OnCleanup handler when the scenario is run")

scenario:Run()

assertEquals(numSetupExecutions, 2, "Should call the OnSetup handler again when the scenario is run twice")
assertEquals(numTestExecutions, 2, "Should call the OnRun handler again when the scenario is run twice")
assertEquals(numEvaluationExecutions, 2, "Should call the OnEvaluate handler again when the scenario is run twice")
assertEquals(numCleanupExecutions, 2, "Should call the OnCleanup handler again when the scenario is run twice")
