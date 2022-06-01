-- TODO Testing, documentation
local C_Testing = {}

function C_Testing.CreateFauxConsole()

	local tostring = tostring

	local fauxConsole = {
		stdoutBuffer = ""
	}

	-- Append string to the stdout buffer
	function fauxConsole.print(...)
		fauxConsole.stdoutBuffer = fauxConsole.stdoutBuffer .. tostring(... or "") .. "\n"
	end

	-- Clear the stdout buffer
	function fauxConsole.clear()
		fauxConsole.stdoutBuffer = ""
	end

	-- Return the contents of the stdout buffer
	function fauxConsole.read()
		return fauxConsole.stdoutBuffer
	end

	return fauxConsole
end

-- EXPORT("C_Testing", C_Testing)
_G.C_Testing = C_Testing