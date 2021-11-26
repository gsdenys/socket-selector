local types = {}

types.NGINX   = require "selector.socket.lua"
types.CQUEUES = require "selector.socket.cqueues"
types.LUA     = require "selector.socket.lua"

return types
