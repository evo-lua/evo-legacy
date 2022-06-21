local vfs = require("virtual_file_system")

-- TBD: Should this be moved to the preloaded vfs package?
describe("vfs", function()
	describe("getErrorMessage", function()
		it("should remove redundant code from errors raised in chunks compiled via loadstring", function()
			local clutteredErrorMessage = "[string \"describe(\"assertThrows\", function()...\"]:5: test"

		local readableErrorMessage = "test"
		assertEquals(vfs.getErrorMessage(clutteredErrorMessage), readableErrorMessage)
		end)
	end)
end)