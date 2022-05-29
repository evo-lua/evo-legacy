-- TODO Testing, documentation
local C_Testing = {}

function C_Testing:CreateFauxConsole()

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

	-- line(lineNo) = return content of line x
	-- lines = count number of lines
	-- dump = print to the actual console, for debugging purposes - or maybe to a file?

	return fauxConsole
end

-- EXPORT("C_Testing", C_Testing)
_G.C_Testing = C_Testing