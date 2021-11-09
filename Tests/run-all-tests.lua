-- Since we don't run the tests from the package root (main.lua), import won't find evo packages normally
-- This isn't something that would be needed when running regular user scripts, since the entry point is always main.lua
-- EVO_PACKAGE_DIRECTORY = "../.evo"

print("Running all tests...\n")

import("Core/test-wrapped-user-script.lua")

import("Builtins/test-aliases.lua")
import("Builtins/test-log.lua")
import("Builtins/test-serialize.lua")
import("Builtins/test-shared-constants.lua")

import("API/test-networking.lua")

print("\nAll tests completed!")