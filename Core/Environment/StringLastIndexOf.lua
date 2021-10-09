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

local function assertEquals(expectedResult, actualResult, descriptor)

	if actualResult ~= expectedResult then
		print(format("FAIL\t%s\t%s IS NOT %s", descriptor, actualResult, expectedResult))
	end

	assert(actualResult == expectedResult, format("\nExpected %s (actual: %s)", expectedResult, actualResult))
	print(format("PASS\t%s\t%s IS %s", descriptor, actualResult, expectedResult))
end

for index, testCase in ipairs(testCases) do

	local actualResult = StringPrototypeLastIndexOf(testStr, testCase.searchValue, testCase.fromIndex)
	assertEquals(testCase.expectedResult, actualResult, index)

	-- if actualResult ~= testCase.expectedResult then
	-- 	print(format("FAIL\t%s IS NOT %s", actualResult, testCase.expectedResult))
	-- end

	-- assert(actualResult == testCase.expectedResult, format("\nExpected %s (actual: %s)", testCase.expectedResult, actualResult))
	-- print(format("PASS\t%s IS %s", actualResult, testCase.expectedResult))
end

print("OK\tStringPrototypeLastIndexOf")

-- assert(StringPrototypeLastIndexOf(testStr, 'a', 2) == 1, "Expected 1")
-- assert(StringPrototypeLastIndexOf(testStr, 'a', 0) == -1, "Expected -1")
-- assert(StringPrototypeLastIndexOf(testStr, 'x') == -1, "Expected -1")
-- assert(StringPrototypeLastIndexOf(testStr, 'c', -5) == 0, "Expected 0")
-- assert(StringPrototypeLastIndexOf(testStr, 'c', 0) == 0, "Expected 0")
-- assert(StringPrototypeLastIndexOf(testStr, '') == 5, "Expected 5")
-- assert(StringPrototypeLastIndexOf(testStr, '', 2) == 2, "Expected 2")

-- V8 test cases below (TODO: Add licensing info)
local s = "test test test";

local MAX_DOUBLE = 1.7976931348623157e+308;
local MIN_DOUBLE = -MAX_DOUBLE;
local MAX_SMI = 2^30 - 1
local MIN_SMI = - 2^30;
local Infinity = math.huge -- #INF (infinity)
local NaN = 0 / 0 -- #IND (indefinite)

function string.lastIndexOf(...)
	return StringPrototypeLastIndexOf(...)
end

assertEquals(10, s:lastIndexOf("test", Infinity), "tinf");
assertEquals(10, s:lastIndexOf("test", MAX_DOUBLE), "tmaxdouble");
assertEquals(10, s:lastIndexOf("test", MAX_SMI), "tmaxsmi");
assertEquals(10, s:lastIndexOf("test", #s * 2), "t2length");
assertEquals(10, s:lastIndexOf("test", 15), "t15");
assertEquals(10, s:lastIndexOf("test", 14), "t14");
assertEquals(10, s:lastIndexOf("test", 10), "t10");
assertEquals(5, s:lastIndexOf("test", 9), "t9");
assertEquals(5, s:lastIndexOf("test", 6), "t6");
assertEquals(5, s:lastIndexOf("test", 5), "t5");
assertEquals(0, s:lastIndexOf("test", 4), "t4");
assertEquals(0, s:lastIndexOf("test", 0), "t0");
assertEquals(0, s:lastIndexOf("test", -1), "t-1");
assertEquals(0, s:lastIndexOf("test", -#s), "t-len");
assertEquals(0, s:lastIndexOf("test", MIN_SMI), "tminsmi");
assertEquals(0, s:lastIndexOf("test", MIN_DOUBLE), "tmindouble");
assertEquals(0, s:lastIndexOf("test", -Infinity), "tneginf");
assertEquals(10, s:lastIndexOf("test"), "t");
assertEquals(-1, s:lastIndexOf("notpresent"), "n");
assertEquals(-1, s:lastIndexOf(), "none");
assertEquals(10, s:lastIndexOf("test", "not a number"), "nan");

local longNonMatch = "overlong string that doesn't match";
local longAlmostMatch = "test test test!";
local longAlmostMatch2 = "!test test test";


assertEquals(-1, s:lastIndexOf(longNonMatch), "long");
assertEquals(-1, s:lastIndexOf(longNonMatch, 10), "longpos");
assertEquals(-1, s:lastIndexOf(longNonMatch, NaN), "longnan");
assertEquals(-1, s:lastIndexOf(longAlmostMatch), "tlong");
assertEquals(-1, s:lastIndexOf(longAlmostMatch, 10), "tlongpos");
assertEquals(-1, s:lastIndexOf(longAlmostMatch), "tlongnan");

local nonInitialMatch = "est";

assertEquals(-1, s:lastIndexOf(nonInitialMatch, 0), "noninit");
assertEquals(-1, s:lastIndexOf(nonInitialMatch, -1), "noninitneg");
assertEquals(-1, s:lastIndexOf(nonInitialMatch, MIN_SMI), "noninitminsmi");
assertEquals(-1, s:lastIndexOf(nonInitialMatch, MIN_DOUBLE), "noninitmindbl");
assertEquals(-1, s:lastIndexOf(nonInitialMatch, -Infinity), "noninitneginf");

for i = #s + 10, 0,  -1 do
	local expected = i < #s and i or #s;
  assertEquals(expected, s:lastIndexOf("", i), "empty" .. i);
end


local reString = "asdf[a-z]+(asdf)?";

assertEquals(4, reString:lastIndexOf("[a-z]+"), "r4");
assertEquals(10, reString:lastIndexOf("(asdf)?"), "r10");

-- // Should use index of 0 if provided index is negative.
-- // See http://code.google.com/p/v8/issues/detail?id=351
local str = "test"
assertEquals(0, str:lastIndexOf("test", -1), "regression");

print("OK\tlastIndexOf")