local json = import("@dhkolf/dkjson/dkjson.lua")

function json.stringify(...)
	return json.encode(...)
end

function json.parse(...)
	return json.decode(...)
end

_G.json = json