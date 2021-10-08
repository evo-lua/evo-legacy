-- Upvalues
local tonumber = tonumber
local string_len = string.len

-- Adapted from the V8 runtime implementation of String.prototype.lastIndexOf
-- See https://github.com/v8/v8/blob/901b67916dc2626158f42af5b5c520ede8752da2/src/runtime/runtime-strings.cc
-- TODO: Add license info

function StringMatchBackwards(subject, pattern, idx)

	local pattern_length = #pattern -- int
	-- DCHECK(pattern_length >= 1);
	-- DCHECK(idx + pattern_length <= subject.length());

	-- -- if (sizeof(schar) == 1 && sizeof(pchar) > 1) {
	-- 	for i = 0, pattern_length, 1 do
	-- 		local c = pattern[i];
	-- 		-- if (c > String::kMaxOneByteCharCode) {
	-- 		-- 	return -1;
	-- 		-- }
	-- 	end
	-- -- }

	local pattern_first_char = string.sub(pattern, 1, 1)
	for i = idx, 0, -1 do

		local characterToCheck = string.sub(subject, i + 1, i + 1)
		if (characterToCheck == pattern_first_char) then
			-- Check the rest of the pattern
			local j = 1;
			while (j < pattern_length) do

				if (string.sub(pattern, j + 1, j + 1) ~= string.sub(subject, i + j + 1, i + j + 1)) then
					break;
				end

				j = j + 1;
			end

			if (j == pattern_length) then
				return i;
			end
		end
	end
	return -1;

end

function StringLastIndexOf(sub, pat, index)

	assert(sub ~= nil, "Usage: StringLastIndexOf(sub, pat, index)")
	assert(pat ~= nil, "Usage: StringLastIndexOf(sub, pat, index)")
	assert(index ~= nil, "Usage: StringLastIndexOf(sub, pat, index)")

	sub = tostring(sub)
	pat = tostring(pat)
	index = tonumber(index)
	assert(type(sub) == "string", "StringLastIndexOf: Argument sub is not a string")
	assert(type(pat) == "string", "StringLastIndexOf: Argument pat is not a string")
	assert(type(index) == "number", "StringLastIndexOf: Argument index is not a number")

	local start_index = index

	local pat_length = #pat;
	local sub_length = #sub;

	if (start_index + pat_length > sub_length) then
	  start_index = sub_length - pat_length;
	end

	if (pat_length == 0) then
	  return start_index
	end

	local position = -1;
	position = StringMatchBackwards(sub, pat, start_index);
	return position
end

function StringPrototypeLastIndexOf(sub, pat, position)

	sub = tostring(sub);
	local subLength = #sub;
	pat = tostring(pat);
	local patLength = #pat;
	local index = subLength - patLength;

	local argc = 0
	if sub ~= nil then argc = argc + 1 end
	if pat ~= nil then argc = argc + 1 end
	if index ~= nil then argc = argc + 1 end

	if (argc > 1) then
		position = tonumber(position);
		if (position ~= nil) then
			position = tonumber(position);
			if (position < 0) then
		  	position = 0;
			end

			if (position + patLength < subLength) then
		 		index = position;
			end
		end
	end

	if (index < 0) then
	  return -1;
	end

	return StringLastIndexOf(sub, pat, index);
end

local testStr = "canal"
local testCases = {
	{ searchValue = "a", fromIndex = nil, expectedResult = 3 },
	{ searchValue = "a", fromIndex = 2, expectedResult = 1 },
	{ searchValue = "a", fromIndex = 0, expectedResult = -1 },
	{ searchValue = "x", fromIndex = nil, expectedResult = -1 },
	{ searchValue = "c", fromIndex = -5, expectedResult = 0 },
	{ searchValue = "c", fromIndex = 0, expectedResult = 0 },
	{ searchValue = "", fromIndex = nil, expectedResult = 5 },
	{ searchValue = "", fromIndex = 2, expectedResult = 2 },
}

local format = string.format

print("StringPrototypeLastIndexOf")

for _, testCase in ipairs(testCases) do
	local actualResult = StringPrototypeLastIndexOf(testStr, testCase.searchValue, testCase.fromIndex)

	if actualResult ~= testCase.expectedResult then
		print(format("FAIL\t%s IS NOT %s", actualResult, testCase.expectedResult))
	end

	assert(actualResult == testCase.expectedResult, format("\nExpected %s (actual: %s)", testCase.expectedResult, actualResult))
	print(format("PASS\t%s IS %s", actualResult, testCase.expectedResult))
end

print("OK\tStringPrototypeLastIndexOf")

-- assert(StringPrototypeLastIndexOf(testStr, 'a', 2) == 1, "Expected 1")
-- assert(StringPrototypeLastIndexOf(testStr, 'a', 0) == -1, "Expected -1")
-- assert(StringPrototypeLastIndexOf(testStr, 'x') == -1, "Expected -1")
-- assert(StringPrototypeLastIndexOf(testStr, 'c', -5) == 0, "Expected 0")
-- assert(StringPrototypeLastIndexOf(testStr, 'c', 0) == 0, "Expected 0")
-- assert(StringPrototypeLastIndexOf(testStr, '') == 5, "Expected 5")
-- assert(StringPrototypeLastIndexOf(testStr, '', 2) == 2, "Expected 2")
