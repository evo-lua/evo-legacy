assert(type(format) == "function", "The format alias should be available")
assert(format == string.format, "The format alias should use the standard Lua implementation")

assert(type(printf) == "function", "The printf alias should be available")

print("OK\tBuiltins\taliases")