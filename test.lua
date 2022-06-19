print("Running all tests...\n")

import("Tests/Core/test-wrapped-user-script.lua")

import("Tests/Primitives/test-scenario-primitive.lua")
import("Tests/Primitives/test-testsuite-primitive.lua")

import("Tests/Builtins/test-aliases.lua")
import("Tests/Builtins/test-event.lua")
import("Tests/Builtins/test-fs.lua")
import("Tests/Builtins/test-json.lua")
import("Tests/Builtins/test-log.lua")
import("Tests/Builtins/test-serialize.lua")
import("Tests/Builtins/test-transform.lua")
import("Tests/Builtins/test-shared-constants.lua")

import("Tests/Extensions/test-table.lua")

import("Tests/API/test-c-filesystem.lua")

import("Tests/Examples/automated-testing/run-my-tests.lua")
import("Tests/Examples/automated-testing/faux-console-usage-example.lua")
import("Tests/Examples/automated-testing/faux-console-injection-example.lua")

print("\nAll tests completed!")