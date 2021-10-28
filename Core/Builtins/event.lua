local event = {
	listeners = {}
}

function event.register(eventID, listener)
	event.listeners[eventID] = event.listeners[eventID] or {}
	event.listeners[eventID][listener] = listener
end

function event.unregister(eventID, listener)
	if not eventID then
		return nil, "Usage: unregister(eventID, listener)"
	end

	local registeredListeners = event.listeners[eventID]
	if not registeredListeners then
		return nil, format("Failed to register listener %s for event %s (no listeners are registered for this event)", listener, eventID)
	end

	if not listener then
		for k, v in pairs(registeredListeners) do
			event.listeners[eventID][k] = nil
		end
	else
		registeredListeners[listener] = nil
	end

	return true
end

function event.trigger(eventID, ...)

	if not eventID then
		return nil, "Usage: trigger(eventID, ...)"
	end

	EVENT(eventID, ...)

	local registeredListeners = event.listeners[eventID]
	if not registeredListeners then
		return nil, "No registered listeners for event " .. eventID
	end

	for listenerID, listener in pairs(registeredListeners) do
		listener(eventID, ...)
	end
end

function event.list(eventID)
	return event.listeners[eventID]
end

_G.event = event