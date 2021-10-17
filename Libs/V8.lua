-- These use JavaScript conventions (indices start at zero) and are only used for the adapted JS code (NodeJS API)
local V8 = {}

-- Adapted from the V8 runtime implementation of String.prototype.lastIndexOf
-- See https://github.com/v8/v8/blob/901b67916dc2626158f42af5b5c520ede8752da2/src/runtime/runtime-strings.cc
-- TODO: Add license info

-- Upvalues
local string_sub = string.sub
local assert = assert
local tonumber = tonumber
local tostring = tostring
local type = type

function V8.StringMatchBackwards(subject, pattern, idx)
	local pattern_length = #pattern
	local pattern_first_char = string_sub(pattern, 1, 1)
	for i = idx, 0, -1 do

		local characterToCheck = string_sub(subject, i + 1, i + 1)
		if (characterToCheck == pattern_first_char) then
			-- Check the rest of the pattern
			local j = 1;
			while (j < pattern_length) do

				if (string_sub(pattern, j + 1, j + 1) ~= string_sub(subject, i + j + 1, i + j + 1)) then
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

function V8.StringLastIndexOf(sub, pat, index)
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
	position = V8.StringMatchBackwards(sub, pat, start_index);
	return position
end

function V8.StringPrototypeLastIndexOf(sub, pat, position)

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

	return V8.StringLastIndexOf(sub, pat, index);
end

return V8