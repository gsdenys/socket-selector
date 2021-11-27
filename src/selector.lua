local table = require "ptable"

local types = require "sselector.types"
local assertion = require "sselector.utils.assertion"
local messages = require "sselector.utils.messages"

-- the socket selector object
local selector = table({})

-- the name of possibles types
local typename = {LUA = "LUA", CQUEUES = "CQUEUES", NGINX = "NGINX"}

-- the default environment variable that overwrite the selector
local defaultenv = "SOCKET_TYPE"

--- Validate the environment variable name. Case one of test fails this function will throw an error.
--
---@param env any the environment variable name
---@param fname any the caller function
local function validate_env_name(env, fname)
    -- env var cannot have white space
    assertion.whitespace(fname, messages.ERR_ENV_WHITE_SPACE, env)

    -- env var cannot be a empty string
    assertion.True(fname, messages.ERR_ENV_EMPTY, env ~= "")
end

--- Validade de value of environment variable. This function assumes that this env var never
--- will be nil and in case of one o more test fails this function will throw an error.
---
---@param env any the environment variable to be tested
---@param fname any the caller function
local function validate_env_value(env, fname)
    -- the env var value cannot contains whitespace
    assertion.whitespace(fname, messages.ERR_SOCKET_WHITE_SPACE, env)

    -- the env var value cannot be a empty string
    assertion.True(fname, messages.ERR_SOCKET_EMPTY_STRING, env ~= "")

    -- the env var value needs to be contained in the typenames table
    assertion.contains(typename, env, messages.ERR_SOCKET_UNKNOWN, fname)
end

--- Get the socket selected
---
--- @usage
---     local selector = require "sselector"
---     local socket = selector.get()
---
--- @return any - the socker selector
function selector:get() return selector.socket end

--- verify if the socket is a lua socket
---
--- @usage
---     local selector = require "sselector"
---     local test = selector.islua() -- it'll return true if it's lua socket
---
--- @return boolean
function selector:islua() return selector.env == typename.LUA end

--- verify if the socket is a cqueues socket
---
--- @usage
---     local selector = require "sselector"
---     local test = selector.iscqueues() -- it'll return true if it's cequeues socket
---
--- @return boolean
function selector:iscqueues() return selector.env == typename.CQUEUES end

--- verify if the socket is a nginx socket
---
--- @usage
---     local selector = require "sselector"
---     local test = selector.isnginx() -- it'll return true if it's nginx socket
---
--- @return boolean
function selector:isnginx() return selector.env == typename.NGINX end


--- get socket based in the environment variable selection
---
--- @param envname string the environment variable
--- @param fname string the caller function name
--- @return table - the table with the socket data
local function from_env(envname, fname)
    local t = table({})

    -- obtain the environment variable name and validate it
    envname = envname or defaultenv and defaultenv
    validate_env_name(envname, fname)

    -- ibtain the envirinment variable value and validte it
    -- case their value is not nil
    local envvalue = os.getenv(envname)
    if envvalue == nil then return t end

    validate_env_value(envvalue, fname)

    -- set the env and socket data
    t.env = envvalue
    t.socket = types[envvalue]

    return t
end

--- obtain the nginx socket data and return true case there is
--- some nginx socket.
---
---@param t any the table to update
---@return boolean - true in case of it is nginx, other else false
local function ngx(t)
    if _G.ngx and _G.ngx.socket then
        t.env = typename.NGINX
        t.socket = types.NGINX

        return true
    end

    return false
end

--- obtain the cqueues socket data and return true case there is
--- cqueues installed.
---
---@param t any the table to update
---@return boolean - true in case of it's cqueues socket, other else false
local function cqueues(t)
    local cq, _ = pcall(require, "cqueues")

    if cq then
        t.env = typename.CQUEUES
        t.socket = types.CQUEUES

        return true
    end

    return false
end

--- discovery wich kind of socket should be used based on the execution
--- environment and the module instaled on.
---
---@return any
local function from_discovery()
    local t = table({})

    -- test if there is nginx socket in the environment. In a positive
    -- case just retun the actualized table
    if ngx(t) then return t end

    -- test if there is cqueues socket in the environment. In a positive
    -- case just retun the actualized table
    if cqueues(t) then return t end

    -- case none of the above test fail, use the default lua socket
    t.env = typename.LUA
    t.socket = types.LUA

    return t
end

--- default builde to create socket selector base object
---
--- @param envname string the name of the used environment variable
--- @return any - the socket selector
local function builder(envname)
    local fname = "builder"

    -- try to get soket based on env variable
    local t = from_env(envname, fname)

    -- case has no environmet socket set, them start discovery
    if t.env ~= nil and t.socket ~= nil then t = from_discovery() end

    -- add the selected docket data to this table
    selector:merge(t)

    return selector
end

return builder()