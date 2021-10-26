-- DEMO: Proof of concept to show how Luvit/Lit packages can easily be used in evo
-- The only issue is that all the imports need to be changed to use import, as evo doesn't modify require
-- and the packages should be organized in the evo package folder; accessed via orga/repo/file format

local ws = import("@creationix/weblit-websocket/weblit-websocket.lua")

dump(ws)
assert(type(ws) == "function", "Should import the weblit-websocket package")

local weblit = import("@creationix/weblit-app/weblit-app.lua")
dump(weblit)
assert(type(weblit) == "table", "Should import the weblit-app package")


-- dump(EVO_MODULE_CACHE)
-- dump(EVO_IMPORT_STACK)
local options = {
	-- host = "0.0.0.0",
	host = "127.0.0.1",
	port = 9001
}

local server = weblit.bind(options)
dump(server)

  -- This is a custom route handler
--   server.route({
--     method = "GET", -- Filter on HTTP verb
--     path = "/greet/:name", -- Filter on url patterns and capture some parameters.
--   }, function (req, res)
--     dump(req) -- Log the entire request table for debugging fun
--     res.body = "Hello " .. req.params.name .. "\n"
--     res.code = 200
--   end)
  -- Websocket layer
  server.websocket({
	path = "/echo", -- Prefix for matching
  }, function (req, read, write)
	-- Log the request headers
	-- dump(req)
	-- Log and echo all messages
	for message in read do
	  write(message)
	end
	-- End the stream
	write()
  end)

  -- Actually start the server
  .start()

  -- Include a few useful middlewares.  Weblit uses a layered approach.
--   .use(require('weblit-logger'))
--   .use(require('weblit-auto-headers'))
--   .use(require('weblit-etag-cache'))
