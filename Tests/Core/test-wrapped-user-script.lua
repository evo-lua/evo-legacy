local currentThread, isMainThread = coroutine.running( )

assert(coroutine.status(currentThread) == "running", "Should be running") -- This is kind of silly, but you never know what might go wrong down the line...
assert(type(currentThread) == "thread", "Should be running in a coroutine")
assert(not isMainThread, "Should NOT be running on the main thread") -- If it runs on the main thread, we can't yield to pause until I/O is ready

print("OK\tCore\t\twrapped-user-script") -- 2 tabs because it's too short a label to be aligned otherwise (hacky)