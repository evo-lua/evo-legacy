
-- TODO tests for this
function assertEquals(firstValue, secondValue)
	assert(firstValue == secondValue, "Expected " .. tostring(firstValue) .. " to be " .. tostring(secondValue))
end

_G.assertEquals = assertEquals