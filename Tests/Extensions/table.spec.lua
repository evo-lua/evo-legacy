describe("Extensions: table library", function()
	describe("count", function()
		it("should return 0 if the table is empty", function()
			assertEquals(table.count({}), 0)
		end)

		it("should return the number of array elements if the hash part is empty", function()
			assertEquals(table.count({ "Hello", "world"}), 2)
		end)

		it("should return the number of hash map entries if the array part is empty", function()
			assertEquals(table.count({Hello = 42, world = 123}), 2)
		end)

		it("should return the total sum of hash map and array entries if neither part is empty", function()
			assertEquals(table.count({ "Hello world", Hello = 42}), 2)
		end)
	end)
end)