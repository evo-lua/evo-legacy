local C_Timer = {}

local uv = require("uv")
function C_Timer.After(timeoutInMilliseconds, callbackFunction)
	DEBUG("Timer created", timeoutInMilliseconds)
	local timer = uv.new_timer()
	timer:start(timeoutInMilliseconds, 0, function ()
		DEBUG("TImer expired")
	  timer:stop()
	  timer:close()
	  callbackFunction()
	end)
	return timer
end

-- EXPORT("C_Timer", C_Timer)
_G.C_Timer = C_Timer