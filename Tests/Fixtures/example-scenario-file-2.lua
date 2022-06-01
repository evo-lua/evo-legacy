local scenario = Scenario:Construct("Asserting some more stuff")

function scenario:OnEvaluate()
	assert(1 == 1, "Some description")
end

return scenario