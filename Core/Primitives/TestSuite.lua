local TestSuite = {}

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
	local instance = {}

	setmetatable(instance, inheritanceLookupMetatable)

	instance.name = name or ""
	instance.scenarios = {}

	print("[TestSuite] Created test suite: " .. instance.name)

	return instance
end

function TestSuite:AddScenarios(listOfScenarios)
	for _, scenarioFilePath in pairs(listOfScenarios) do
		local scenario = import(scenarioFilePath)
		self:AddScenario(scenario)
	end
end

function TestSuite:Run()
	self:RunAllScenarios()
end

function TestSuite:AddScenario(scenario)
	print("[TestSuite] Added scenario: " .. scenario:GetName())
	self.scenarios[#self.scenarios + 1] = scenario
end

function TestSuite:RunAllScenarios()
	print("[TestSuite] Running all scenarios")
	for scenarioID, scenario in ipairs(self.scenarios) do
		self:RunScenario(scenario)
	end

	self:PrintSummary()
end

function TestSuite:RunScenario(scenario)
	if not scenario then
		print("[TestSuite] Skipping invalid scenario")
		return
	end

	print("[TestSuite] Running scenario " .. scenario:GetName())
	scenario:Run()
	print()
end

function TestSuite:PrintSummary()
	print("--------------------------------------------------------------------------------") -- 80 chars to fit terminals
	print()
	print(transform.cyan("Test Suite: ") .. transform.white(self.name))
	print()

	local numFailedScenarios = 0

	for scenarioID, scenario in ipairs(self.scenarios) do
		local successIcon = transform.green("✓")
		if scenario:HasFailed() then
			successIcon = transform.red("✗")
			numFailedScenarios = numFailedScenarios + 1
		end

		local resultsText = scenario:GetSummaryText()

		local summaryText = format("\t%s %s: %s", successIcon, scenario:GetName(), resultsText)
		print(summaryText)
	end

	print()

	if numFailedScenarios == 1 then -- OCD...
		print(transform.brightRedBackground("1 scenario failed"))
	elseif numFailedScenarios > 1 then
		print(transform.brightRedBackground(format("%s scenarios failed!", numFailedScenarios)))
	else
		print("All scenarios completed successfully!")
	end
end

_G.TestSuite = TestSuite

return TestSuite
