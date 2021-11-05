local socket = {}

-- stream handle
-- uv.shutdown(stream, [callback])
function socket.shutdown()

end

-- uv.listen(stream, backlog, callback)
function socket.listen()

end

-- uv.accept(stream, client_stream)
function socket.accept()

end

-- uv.read_start(stream, callback)
function socket.readstart()

end

-- uv.read_stop(stream)
function socket.readstop()

end

-- uv.write(stream, data, [callback])
function socket.write(data, onWriteFinished)

end

-- uv.try_write(stream, data)
-- uv.is_readable(stream)
function socket.isReadable()

end

-- uv.is_writable(stream)
function socket.isWritable()

end

-- uv.stream_get_write_queue_size()

-- tcp handle
-- uv.new_tcp([flags])
function socket.create()

end

-- uv.tcp_open(tcp, sock)
function socket.open(handle)

end

-- uv.tcp_nodelay(tcp, enable)
function socket.setnodelay()

end

-- uv.tcp_keepalive(tcp, enable, [delay])
function socket.setkeepalive()

end

-- uv.tcp_bind(tcp, host, port, [flags])
function socket.bind()

end

-- uv.tcp_getpeername(tcp)
function socket.peername()

end

-- uv.tcp_getsockname(tcp)
function socket.name()

end

-- uv.tcp_connect(tcp, host, port, callback)
function socket.connect()

end

-- uv.tcp_close_reset([callback])
-- TBD: yield?
function socket.reset(onResetFinishedCallback)

end



_G.socket = socket