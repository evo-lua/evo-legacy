local MyAPI = {}

function MyAPI:PrintHelloWorld(console)
	-- Simply omit the console parameter to print to the "real" terminal window instead
	local print = console and console.print or print
	print("Hello world!") -- Prints to the fauxConsole if one was passed, and stdout otherwise
end

-- Now the output can easily be tested, without affecting the logic of your program
local fauxConsole = C_Testing.CreateFauxConsole()

MyAPI:PrintHelloWorld() -- Doesn't use the virtual console (visible console output WILL occur)
assertEquals(fauxConsole.read(), "", "Should print to stdout if no console parameter was passed")
MyAPI:PrintHelloWorld(fauxConsole) -- DOES use the virtual console (no visible console output will occur)
assertEquals(fauxConsole.read(), "Hello world!\n", "Should write to the buffer if a console parameter was passed")

return MyAPI
