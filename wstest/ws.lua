require("weblit-websocket")
local app = require('weblit-app')

  .bind({
    -- host = "0.0.0.0",
    port = 8080
  })

--   .use(require('weblit-logger'))
--   .use(require('weblit-auto-headers'))
--   .use(require('weblit-etag-cache'))

--   .route({
--     method = "GET",
--     path = "/do/:user/:action",
--     domain = "*.myapp.io"
--   }, function (req, res, go)
--     -- Handle route
--   end)

  .websocket({
	path = "/echo", -- Prefix for matching
	-- protocol = "virgo/2.0", -- Restrict to a websocket sub-protocol
  }, function (req, read, write)
	-- Log the request headers
	-- p(req)
	-- Log and echo all messages
	for message in read do
	  write(message)
	end
	-- End the stream
	write()
  end).start()