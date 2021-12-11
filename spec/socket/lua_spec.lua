require 'busted.runner'()

local function start_server()
    local tmpfile = '/tmp/stmp.txt'
    os.execute("lua $(pwd)/spec/server.lua & echo $! >" .. tmpfile)

    local handle = io.open(tmpfile)
    local pid = handle:read("*a")
    handle:close()

    return pid
end

describe("Lua socket", function()
    describe("Connection", function()
        it("should connect successfully", function()
            local pid = start_server()

            local ctx = require "selector.lua"
            local status, retval = pcall(ctx.connect, ctx, "127.0.0.1", 8000)

            os.execute("kill " .. pid)

            assert.True(status)
            assert.equal(ctx, retval)
        end)
    end)

    describe("operations", function()
        local ctx = require "selector.lua"
        local pid = 0

        setup(function()
            pid = start_server()
            ctx:connect("127.0.0.1", 8000)
        end)

        teardown(function() os.execute("kill " .. pid) end)

        it("should send message", function()
            local message = "some test"
            local res = ctx:send(message)

            assert.not_nil(res)
            assert.equal(#message, res)
        end)

        it("should receive message", function()

            local message = "some test"
            local res = ctx:receive(5)
            print(res)
            -- assert.not_nil(res)
            -- assert.equal(#message, res)
        end)
    end)
end)
