local TestSuite = {
	-- 80 chars to fit greybeard terminals
	HORIZONTAL_LINE_SEPARATOR = "--------------------------------------------------------------------------------"
}

local setmetatable = setmetatable
local rawget = rawget
local format = string.format

local inheritanceLookupMetatable = {
	__index = function(t, v)
		if TestSuite[v] then
			return TestSuite[v]
		else
			return rawget(t, v)
		end
	end
}

function TestSuite:Construct(name)
	local instance = {
		name = name or "",
		scenarios = {}
	}

	setmetatable(instance, inheritanceLookupMetatable)


-- 	print("[TestSuite] Created test suite: " .. instance.name)

	return instance
end

function TestSuite:GetNumScenarios()
	return #self.scenarios
end

function TestSuite:Run(console)
	self:RunAllScenarios(console)
end

function TestSuite:AddScenario(scenario)
-- 	print("[TestSuite] Added scenario: " .. scenario:GetName())
	self.scenarios[#self.scenarios + 1] = scenario
end

function TestSuite:AddScenarios(listOfScenarios)
	-- 	for _, scenarioFilePath in pairs(listOfScenarios) do
	-- 		local scenario = import(scenarioFilePath)
	-- 		self:AddScenario(scenario)
	-- 	end
end

function TestSuite:RunAllScenarios(console)
-- 	print("[TestSuite] Running all scenarios")
	for scenarioID, scenario in ipairs(self.scenarios) do
		self:RunScenario(scenario)
	end

	self:ReportSummary(console)
end

function TestSuite:RunScenario(scenario)
	if not scenario then
-- 		print("[TestSuite] Skipping invalid scenario")
		return
	end

-- 	print("[TestSuite] Running scenario " .. scenario:GetName())
	scenario:Run()
-- 	print()
end

function TestSuite:ReportSummary(console)
	local printMethod = console and console.print or print
	printMethod(self.HORIZONTAL_LINE_SEPARATOR)
	printMethod()
	printMethod(transform.cyan("Test Suite: ") .. transform.white(self.name))
	printMethod()

	local numFailedScenarios = 0

	-- If no scenarios have been added, this is a NOOP and can be ignored
	for scenarioID, scenario in ipairs(self.scenarios) do
		local successIcon = transform.green("✓")
		if scenario:HasFailed() then
			successIcon = transform.red("✗")
			numFailedScenarios = numFailedScenarios + 1
		end

		local resultsText = scenario:GetSummaryText()

		local summaryText = format("\t%s %s: %s", successIcon, scenario:GetName(), resultsText)
		printMethod(summaryText)
	end

	if #self.scenarios > 0 then printMethod() end -- Extra newline increases readability

	if numFailedScenarios == 1 then -- OCD...
		printMethod(transform.brightRedBackground("1 scenario failed!"))
	elseif numFailedScenarios > 1 then
		printMethod(transform.brightRedBackground(format("%s scenarios failed!", numFailedScenarios)))
	elseif #self.scenarios == 0 then
		printMethod(transform.yellow("Warning: No scenarios to run (technically passing...)"))
	else
		printMethod(transform.green("All scenarios completed successfully!"))
	end
end

-- EXPORT("TestSuite", TestSuite)
_G.TestSuite = TestSuite

return TestSuite
