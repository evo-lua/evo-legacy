
assert(type(event) == "table", "The event builtin should be exported")

local exportedApiSurface = {
	"register",
	"unregister",
	"trigger",
	"list",
}

for index, functionName in pairs(exportedApiSurface) do
	assert(type(event[functionName]) == "function", format("Should export function %s()", functionName))
end

local triggeredEvents = {
	["TEST_EVENT"] = {},
}

local function onEvent(eventID, ...)
	triggeredEvents[eventID] = triggeredEvents[eventID] or {}
	local eventLogEntry = {
		name = eventID,
		arguments = { ... }
	}
	table.insert(triggeredEvents[eventID], eventLogEntry)
end

-- Scenario: Notify listeners for a registered event (common case)
assert(#triggeredEvents["TEST_EVENT"] == 0, "Should not call an event listener before it was registered")
event.register("TEST_EVENT", onEvent)
assert(#triggeredEvents["TEST_EVENT"] == 0, "Should not notify registered event listeners before a relevant event was triggered")
event.trigger("TEST_EVENT")
assert(#triggeredEvents["TEST_EVENT"] == 1, "Should notify registered event listeners after a relevant event was triggered")

-- Scenario: Triggering an event to which no listeners are registered
assert(event.trigger("DOES_NOT_EXIST") == nil, "Should do nothing when called with an event ID that has no registered listeners")
assert(event.trigger() == nil, "Should do nothing when called with invalid parameters (nil)")

assert(event.list("DOES_NOT_EXIST") == nil, "Should return nil if trying to list registered handlers for an event that has none")
assert(event.list() == nil, "Should return nil if trying to list registered handlers without passing an event ID")
assert(table.count(event.list("TEST_EVENT")) == 1, "Should return all registered handlers when listing handlers for an event that has any")

-- Scenario: Unregistering a previously-installed listener
assert(event.unregister() == nil, "Should return nil if trying to unregister without passing an event ID")
assert(event.unregister(nil, onEvent) == nil, "Should return nil if trying to unregister without passing an event ID")
assert(event.unregister("DOES_NOT_EXIST") == nil, "Should return nil if trying to unregister without passing an event listener")
assert(event.unregister("TEST_EVENT", onEvent) == true, "Should return true when successfully unregistering a listener from receiving notifications for an event ")
assert(table.count(event.list("TEST_EVENT")) == 0, "Should successfully remove a specific event listener")
event.register("TEST_EVENT", onEvent)
assert(table.count(event.list("TEST_EVENT")) == 1, "Should Should successfully re-add a specific event listener  ")
assert(event.unregister("TEST_EVENT") == true, "Should return true when successfully unregistering a listener from receiving notifications for all events ")
assert(table.count(event.list("TEST_EVENT")) == 0, "Should return ")

print("OK\tBuiltins\tevent")