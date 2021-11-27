local table = require "ptable"
local socket = require "socket"

local ctx = table({socket = socket, tcp = socket.tcp})

function ctx:send(str) return self.socket.send(str) end

function ctx:receive(int) return self.socket.receive(int) end

function ctx.get_sock()
    -- local sock, err = self.tcp()
    -- if err ~= nil then end
end

return ctx
