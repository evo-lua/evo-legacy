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
		assertPostconditions = NOOP_FUNCTION,
		cleanupFunction = NOOP_FUNCTION
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

function Scenario:FINALLY(cleanupFunction)
	if type(cleanupFunction) ~= "function" then
		return
	end

	self.cleanupFunction = cleanupFunction
end

function Scenario:HasCleanupFunction()
	return self.cleanupFunction ~= NOOP_FUNCTION
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

function Scenario:Run(console)
	local printFunction = console and console.print or print

	local startTime = time()

	self:establishPreconditions()
	self:runTestCode()

	local globalAssert = assert

	local silentAssert = function(condition, description)
		local isConditionTrue = condition

		description = description or "<No Description>"

		local assertionDetails = {
			description = description,
			isSuccess = isConditionTrue
		}
		self.assertions[#self.assertions + 1] = assertionDetails
	end

	_G.assert = silentAssert
	self:assertPostconditions()
	_G.assert = globalAssert

	local endTime = time()
	local runTime = (endTime - startTime) -- high precision = nanoseconds
	local runTimeInMilliseconds = runTime / 10E6
	self.runTimeInMilliseconds = runTimeInMilliseconds

	self.cleanupFunction()

	self:PrintResults(console)
end

function Scenario:ToString()
	local hasResults = self:GetResultsText() ~= ""

	return self:GetOverviewText() .. "\n"
	-- Displaying the number of assertions is pointless if there are none, but if any are present the summary needs more space
	 .. self:GetResultsText() .. (hasResults and "\n" or "")
	 .. self:GetSummaryText()
end

function Scenario:GetOverviewText()
	local displayText = ""

	local LINEBREAK = "\n"
	local INDENT = "\t"

	displayText = displayText .. LINEBREAK
	displayText = displayText .. INDENT .. transform.cyan("Scenario: ") .. transform.white(self.name) .. LINEBREAK
	displayText = displayText .. LINEBREAK

	local preconditionsText = (self.descriptions.GIVEN == "") and "(no description)" or self.descriptions.GIVEN
	if self.establishPreconditions == NOOP_FUNCTION then preconditionsText = "(no preconditions)" end

	local scriptText = (self.descriptions.WHEN == "") and "(no description)" or self.descriptions.WHEN
	if self.runTestCode == NOOP_FUNCTION then scriptText = "(no code to execute)" end

	local postconditionsText = (self.descriptions.THEN == "") and "(no description)" or self.descriptions.THEN
	if self.assertPostconditions == NOOP_FUNCTION then postconditionsText = "(no postconditions)" end

	displayText = displayText .. INDENT .. transform.cyan("GIVEN") .. INDENT .. transform.white(preconditionsText) .. LINEBREAK
	displayText = displayText .. INDENT .. transform.cyan("WHEN") .. INDENT .. transform.white(scriptText) .. LINEBREAK
	displayText = displayText .. INDENT .. transform.cyan("THEN") .. INDENT .. transform.white(postconditionsText) .. LINEBREAK

	return displayText

end

function Scenario:GetResultsText()

	local coloredResultsText = ""
	local failedAssertionCount = 0

	for assertionID, assertionDetails in ipairs(self.assertions) do
		local description = assertionDetails.description
		local isSuccess = assertionDetails.isSuccess

		local successText = transform.yellow("﹖")

		-- Explicitly checking here to avoid nil being interpreted as false
		if isSuccess == true then
			successText = transform.green("✓")
		end
		if isSuccess == false then
			successText = transform.red("✗")
			failedAssertionCount = failedAssertionCount + 1
		end

		coloredResultsText = coloredResultsText .. (format("\t\t%s %s", successText, description)) .. "\n"
	end

	return coloredResultsText
end

function Scenario:GetSummaryText()
	local totalAssertionCount = #self.assertions
	local failedAssertionCount = self:GetNumFailedAssertions()

	local coloredSummaryText
	if failedAssertionCount == 0 then
		coloredSummaryText =
			format("%s passing (%.2f ms)", totalAssertionCount - failedAssertionCount, self.runTimeInMilliseconds)
	end

	if failedAssertionCount > 0 then
		coloredSummaryText = transform.brightRedBackground(format("%s FAILED assertions!", failedAssertionCount))
	end

	if failedAssertionCount == 1 then -- OCD
		coloredSummaryText = transform.brightRedBackground(("1 FAILED assertion!"))
	end

	if totalAssertionCount == 0 then
		coloredSummaryText = transform.yellow("Warning: Nothing to assert (technically passing...)")
	end

	return coloredSummaryText
end

function Scenario:PrintResults(console)
	local printFunction = console and console.print or print
	printFunction(self:ToString())
end

function Scenario:GetName()
	return self.name or ""
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
