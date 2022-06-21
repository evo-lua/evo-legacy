local ffi = require("ffi")
local uv = require("uv")

describe("typeof", function()

	it("should return the default Lua type for objects that aren't tables", function()
		assertEquals(typeof(42), "number")
		assertEquals(typeof("Hello"), "string")
		assertEquals(typeof(true), "boolean")
		assertEquals(typeof(print), "function")
		assertEquals(typeof(ffi.new("uint8_t")), "cdata")
		assertEquals(typeof(uv.new_timer()), "userdata")
		assertEquals(typeof(nil), "nil")
		assertEquals(typeof(coroutine.running()), "thread")
	end)

	it("should return the default Lua type for tables without a __className field", function()
		local tableWithoutClassName = {}

		assertEquals(typeof(tableWithoutClassName), "table")
	end)

	it("should return the default Lua type for tables with a non-string __className field value", function()
		local tableWithNonStringClassName = {
			__className = 42
		}

		assertEquals(typeof(tableWithNonStringClassName), "table")
	end)

	it("should return the value of a table's __className field if it's a string value", function()
		local tableWithStringClassName ={
			__className = "SomeClassName"
		}

		assertEquals(typeof(tableWithStringClassName), "SomeClassName")
	end)

end)