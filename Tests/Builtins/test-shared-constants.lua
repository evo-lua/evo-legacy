-- Upvalues
local assert = assert
local type = type

assert(type(EVO_VERSION_MAJOR) == "number", "Should export the MAJOR version")
assert(type(EVO_VERSION_MINOR) == "number", "Should export the MINOR version")
assert(type(EVO_VERSION_PATCH) == "number", "Should export the PATCH version")
assert(type(EVO_VERSION_STRING) == "string", "Should export the version as string")

print("OK\tBuiltins\tshared-constants")