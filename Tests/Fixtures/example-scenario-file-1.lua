local scenario = Scenario:Construct("Asserting some stuff")

function scenario:OnEvaluate()
	assert(1 == 1, "Some description")
end

return scenario