describe("assertThrows", function()

	it("should not raise an error if the code under test raises the expected error", function()
		local function codeUnderTest()
			error("test")
		end

		local success, errorMessage = pcall(assertThrows, codeUnderTest, "test")
		assertTrue(success)
		assertEquals(errorMessage, nil)
	end)

	it("should raise an error if the code under test doesn't raise an error", function()
		local function codeUnderTest()
			-- Does nothing, in particular doesn't raise an error...
		end
		local success, errorMessage = pcall(assertThrows, codeUnderTest, "test")
		assertFalse(success)
		assertEquals(errorMessage, nil)
	end)

	it("should raise an error if the code under test raises a different error", function()
		local function codeUnderTest()
			error("wrong")
		end

		local success, errorMessage = pcall(assertThrows, codeUnderTest, "test")
		assertFalse(success)
		assertEquals(errorMessage, nil)
	end)

end)