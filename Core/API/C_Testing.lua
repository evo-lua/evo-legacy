-- TODO Testing, documentation, luacheckrc
local C_Testing = {}

function C_Testing:CreateFauxConsole()

	local tostring = tostring

	local fauxConsole = {
		stdoutBuffer = ""
	}

	function fauxConsole.print(...)
		fauxConsole.stdoutBuffer = fauxConsole.stdoutBuffer .. tostring(... or "") .. "\n"
	end

	function fauxConsole.clear()
		fauxConsole.stdoutBuffer = ""
	end

	function fauxConsole.read()
		return fauxConsole.stdoutBuffer
	end

	return fauxConsole
end

-- EXPORT("C_Testing", C_Testing)
_G.C_Testing = C_Testing