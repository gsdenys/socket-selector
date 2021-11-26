local table = require "ptable"

local types = require "sselector.types"
local assertion = require "sselector.utils.assertion"
local messages = require "sselector.utils.messages"

local selector = table({})

local typename = {LUA = "LUA", CQUEUES = "CQUEUES", NGINX = "NGINX"}

local defaultenv = "SOCKET_TYPE"

local function validate_env_name(env, fname)
    -- env var cannot have white space
    assertion.whitespace(fname, messages.ERR_ENV_WHITE_SPACE, env)

    -- env var cannot be a empty string
    assertion.True(fname, messages.ERR_ENV_EMPTY, env ~= "")
end

local function validate_env_value(env, fname)
    assertion.whitespace(fname, messages.ERR_SOCKET_WHITE_SPACE, env)
    assertion.True(fname, messages.ERR_SOCKET_EMPTY_STRING, env ~= "")
    assertion.contains(types:keys(), env, messages.ERR_SOCKET_UNKNOWN, fname)
end

function selector:get() return selector.socket end

function selector:is_lua() return selector.env == typename.LUA end

function selector:is_cqueues() return selector.env == typename.CQUEUES end

function selector:is_nginx() return selector.env == typename.NGINX end

local selector_factory = {}

local function from_env(envname, fname)
    
    local t = table({})

    envname = envname or defaultenv and defaultenv
    validate_env_name(envname, fname)

    local envvalue = os.getenv(envname)
    if envvalue == nil then return t end

    validate_env_value(envvalue, fname)

    t.env = envvalue
    t.socket = types[envvalue]

    return t
end

local function ngx(t)
    if _G.ngx and _G.ngx.socket then
        t.env = typename.NGINX
        t.socket = types.NGINX

        return true
    end

    return false
end

local function cqueues(t)
    local cq, _ = pcall(require, "cqueues")

    if cq then
        t.env = typename.CQUEUES
        t.socket = types.CQUEUES

        return true
    end

    return false
end

local function from_discovery()
    local t = table({})

    if ngx(t) then return t end

    if cqueues(t) then return t end

    t.env = typename.LUA
    t.socket = types.LUA

    return t
end

function selector_factory.New(envname)
    local fname = "New"

    local t = from_env(envname, fname)

    if t.env ~= nil and t.socket ~= nil then t = from_discovery() end

    selector:merge(t)

    return selector
end

return selector_factory
