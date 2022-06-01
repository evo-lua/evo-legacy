local testSuite = import("./my-test-suite.lua")
-- For CI pipelines, ensure the return code indicates EXIT_FAILURE if at least one assertion has failed
assert(testSuite:Run(), "Assertion failure in test suite my-test-suite.lua")