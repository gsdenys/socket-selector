local table = require "ptable"
local socket = require("socket")

local ctx = table({tcp = assert(socket.tcp())})

function ctx:connect(...)
    local ok = self.tcp:connect(...)
    if ok ~= 1 then error(ok) end

    return ctx
end

function ctx:send(str) return self.tcp:send(str) end

function ctx:receive(int) return self.tcp:receive(int) end

return ctx
