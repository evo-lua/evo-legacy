
local fsLoader = package.preload["fs"]
assert(type(fsLoader) == "function", "The fs builtin should be preloaded")


-- It's not the recommended interface due to its low-level nature, but if so desired user scripts can require it directly
local requiredFS = require("fs")
assert(fsLoader() == requiredFS, "The fs builtin can be required")

print("OK\tBuiltins\tfs")