-- Copyright 2021 gsdenys. All Rights Reserved.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http:--www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

--- check if envirinment has ngx socket provider
local function has_ngx_socket()
    if _G.ngx and _G.ngx.socket then
        return true 
    end

    return false
end

--- check if the environmewto has the cqueues socket
local function has_cqueues_socket()
    local cqueues, lfs = pcall(require,"cqueues")
    if cqueues then
        return return true
    end

    return false
end

--- get the apropriate socket, it'll choose based on the library 
--- recognition. There is an order to test the libraries and select 
--- the value, this order is:
---    1. NGINX Socket
---    2. Cqueues Socket
---    3. Lua socket 
local function get_env()
    if has_ngx_socket() then
        return require 'selector.ngx'
    end

    if has_cqueues_socket() then
        return require 'selector.cqueues'
    end

    return require 'selector.lua'
end

return {
    ['get_env'] = get_env
}
