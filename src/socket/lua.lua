local table = require "ptable"
local socket = require "socket"

local ctx = table({socket = socket, tcp = socket.tcp, sock = nil})

function ctx:send(str) return self.socket.send(str) end

function ctx:receive(int) return self.socket.receive(int) end

local function new()
    local sock, err = ctx.tcp()
    if err ~= nil then error("teste", "ERR") end

    ctx.sock = sock

    return ctx
end

return new()
