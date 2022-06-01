print("Running all tests...\n")

import("Core/test-wrapped-user-script.lua")

import("Builtins/test-aliases.lua")
import("Builtins/test-assertions.lua")
import("Builtins/test-event.lua")
import("Builtins/test-fs.lua")
import("Builtins/test-json.lua")
import("Builtins/test-log.lua")
import("Builtins/test-serialize.lua")
import("Builtins/test-transform.lua")
import("Builtins/test-shared-constants.lua")

import("Extensions/test-table.lua")

import("API/test-c-filesystem.lua")

print("\nAll tests completed!")