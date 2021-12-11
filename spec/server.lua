
local socket = require("socket")
-- local string = require("string")

-- create a TCP socket and bind it to the local host, at any port
local server = assert(socket.bind("*", 8000))
local ip, port = server:getsockname()

-- print(string.format("Server %s %s", ip, port))

local running = 1

while 1 == running do
    local client = server:accept()
    client:settimeout(5)
    local msg, err = client:receive()
    while not err and "quit" ~= msg do
        client:send(msg)
        msg, err = client:receive()
    end
    client:close()
end
server:close()