local uv = require("uv")

local format = string.format
local setmetatable = setmetatable
local rawget = rawget
local print = print

local time = uv.hrtime

local NOOP_FUNCTION = function()
end

local Scenario = {
	name = ""
}

local inheritanceLookupMetatable = {
	__index = function(t, v)
		if Scenario[v] then
			return Scenario[v]
		else
			return rawget(t, v)
		end
	end
}

function Scenario:Construct(name)
	local instance = {
		name = name or "",
		runTimeInMilliseconds = 0,
		descriptions = {
			GIVEN = "",
			WHEN = "",
			THEN = ""
		},
		assertions = {},
		establishPreconditions = NOOP_FUNCTION,
		runTestCode = NOOP_FUNCTION,
		assertPostconditions = NOOP_FUNCTION
	}

	setmetatable(instance, inheritanceLookupMetatable)

	return instance
end

function Scenario:GIVEN(description, establishPreconditions)
	if not description or type(establishPreconditions) ~= "function" then
		return
	end

	self.descriptions.GIVEN = description
	self.establishPreconditions = establishPreconditions
end

function Scenario:FINALLY(cleanupCode)
	-- TODO
end

function Scenario:WHEN(description, runTestCode)
	if not description or type(runTestCode) ~= "function" then
		return
	end

	self.descriptions.WHEN = description
	self.runTestCode = runTestCode
end

function Scenario:THEN(description, assertPostconditions)
	if not description or type(assertPostconditions) ~= "function" then
		return
	end

	self.descriptions.THEN = description
	self.assertPostconditions = assertPostconditions
end

function Scenario:Run(printResultsFunction)
	printResultsFunction = printResultsFunction or print
	printResultsFunction("[Scenario] Running scenario: " .. self.name)

	printResultsFunction("[Scenario] Establishing pre-conditions")
	self:establishPreconditions()

	printResultsFunction("[Scenario] Executing test function")
	self:runTestCode()

	printResultsFunction("[Scenario] Asserting post-conditions")
	local globalAssert = assert

	local silentAssert = function(condition, description)
		local isConditionTrue = condition

		description = description or "<No Description>"

		if not isConditionTrue then
			printResultsFunction("[Scenario] Assertion failed: " .. description)
		end
		local assertionDetails = {
			description = description,
			isSuccess = isConditionTrue
		}
		self.assertions[#self.assertions + 1] = assertionDetails
	end

	local function assertEquals(firstValue, secondValue, description)
		if firstValue ~= secondValue then
			error("Failed asserting that " .. tostring(firstValue) .. " equals " .. tostring(secondValue))
		end
		silentAssert(firstValue == secondValue, description)
	end

	_G.assert = silentAssert
	self:assertPostconditions()
	_G.assert = globalAssert
	-- _G.assertEquals = assertEquals

	self:PrintResults()
end

function Scenario:PrintResults(printResultsFunction)
	printResultsFunction = printResultsFunction or print
	printResultsFunction()
	printResultsFunction("\t" .. transform.cyan("Scenario: ") .. transform.white(self.name))
	printResultsFunction()
	printResultsFunction("\t" .. transform.cyan("GIVEN") .. "\t" .. transform.white(self.descriptions.GIVEN))
	printResultsFunction("\t" .. transform.cyan("WHEN") .. "\t" .. transform.white(self.descriptions.WHEN))
	printResultsFunction("\t" .. transform.cyan("THEN") .. "\t" .. transform.white(self.descriptions.THEN))
	printResultsFunction()

	local failedAssertionCount = 0

	local startTime = time()

	for assertionID, assertionDetails in ipairs(self.assertions) do
		local description = assertionDetails.description
		local isSuccess = assertionDetails.isSuccess

		local successText = "TBD"

		-- Explicitly checking here to avoid nil being interpreted as false
		if isSuccess == true then
			successText = transform.green("✓")
		end
		if isSuccess == false then
			successText = transform.red("✗")
			failedAssertionCount = failedAssertionCount + 1
		end

		printResultsFunction(format("\t\t%s %s", successText, description))
	end

	-- exit code 0 or 1
	local endTime = time()
	local runTime = (endTime - startTime) -- high precision = nanoseconds
	local runTimeInMilliseconds = runTime / 10E6

	self.runTimeInMilliseconds = runTimeInMilliseconds

	local coloredResultsText = self:GetResultsText()

	printResultsFunction()
	printResultsFunction(coloredResultsText)
end

function Scenario:GetName()
	return self.name or ""
end

function Scenario:GetResultsText()
	local totalAssertionCount = #self.assertions
	local failedAssertionCount = self:GetNumFailedAssertions()

	local coloredResultsText
	if failedAssertionCount == 0 then
		coloredResultsText =
			format("%s passing (%.2f ms)", totalAssertionCount - failedAssertionCount, self.runTimeInMilliseconds)
	end

	if failedAssertionCount > 0 then
		coloredResultsText = transform.brightRedBackground(format("%s FAILED assertions!", failedAssertionCount))
	end

	if failedAssertionCount == 1 then -- OCD
		coloredResultsText = transform.brightRedBackground(("1 FAILED assertion!"))
	end

	if totalAssertionCount == 0 then
		coloredResultsText = transform.yellow("Warning: Nothing to assert (technically passing...)")
	end

	return coloredResultsText
end

function Scenario:GetNumFailedAssertions()
	local failedAssertionCount = 0

	for assertionID, assertionDetails in ipairs(self.assertions) do
		local isSuccess = assertionDetails.isSuccess

		-- Explicitly checking here to avoid nil being interpreted as false
		if isSuccess == false then
			failedAssertionCount = failedAssertionCount + 1
		end
	end

	return failedAssertionCount
end

function Scenario:HasFailed()
	return self:GetNumFailedAssertions() > 0
end

_G.Scenario = Scenario

return Scenario
