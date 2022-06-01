local fauxConsole = C_Testing.CreateFauxConsole()

assertEquals(fauxConsole.read(), "", "The console buffer should be empty before outputting any text")

fauxConsole.print("This text will never see the light of day!")
-- Beware: A newline (\n) symbol is added to the end, just like in a real console!
assertEquals(fauxConsole.read(), "This text will never see the light of day!\n", "The console should buffer all outputs")

fauxConsole.clear()

assertEquals(fauxConsole.read(), "", "The console buffer should be empty after it was cleared")