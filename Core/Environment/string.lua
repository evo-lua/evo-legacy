-- Splits a string into tokens separated by a given delimiter.
-- Note: This is inspired by PHP's explode function
-- @param inputString The string to process
-- @param[opt] delimiter The delimiter
-- @return A table containing the individual tokens
-- todo split?
function string.explode(inputString, delimiter)
	if type(inputString) ~= "string" then
		return {}
	end

	delimiter = delimiter or "%s" -- Use whitespace by default
	if type(delimiter) == "table" then
		-- use multiple delimiters
		local delimiterPattern = ""
		for k, v in pairs(delimiter) do
			delimiterPattern = delimiterPattern .. v
		end
		delimiter = delimiterPattern
	end

	local tokens = {}
	for token in string_gmatch(inputString, "([^" .. delimiter .. "]+)") do
		table_insert(tokens, token)
	end
	return tokens
end