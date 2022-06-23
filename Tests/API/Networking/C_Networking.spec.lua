describe("C_Networking", function()
	it("should export the TcpSocket builtin", function()
		assertEquals(C_Networking.TcpSocket, import("../../../Core/API/Networking/TcpSocket.lua"))
	end)

	it("should export the TcpClient builtin", function()
		assertEquals(C_Networking.TcpClient, import("../../../Core/API/Networking/TcpClient.lua"))
	end)

	it("should export the TcpServer builtin", function()
		assertEquals(C_Networking.TcpServer, import("../../../Core/API/Networking/TcpServer.lua"))
	end)
end)