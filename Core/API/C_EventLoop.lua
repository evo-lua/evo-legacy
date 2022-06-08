local C_EventLoop = {
	-- External tasks that don't support libuv handles should still integrate with the event loop
	scheduledTasks = {}
}

function C_EventLoop.ScheduleAsyncTask(onUpdateFunction)
	if type(onUpdateFunction) ~= "function" then return end

	table.insert(C_EventLoop.scheduledTasks, onUpdateFunction)
end

local ipairs = ipairs

function C_EventLoop.RunAsyncTasks()
	-- DEBUG("Running " .. #C_EventLoop.scheduledTasks .. " async task(s)")

	for taskID, taskExecutionFunction in ipairs(C_EventLoop.scheduledTasks) do
		taskExecutionFunction()
	end
end

function C_EventLoop.HasAsyncTasks()
	return #C_EventLoop.scheduledTasks > 0
end

function C_EventLoop.GetNumScheduledTasks()
	return #C_EventLoop.scheduledTasks
end

_G.C_EventLoop = C_EventLoop