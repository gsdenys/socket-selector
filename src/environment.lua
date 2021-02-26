


local function has_ngx_socket()
    if _G.ngx and _G.ngx.socket then
        return true 
    end
end

local function has_cqueues_socket()
    
end

local function getEnv()
    if has_ngx_socket then
        return 
    end

    local cqueues, lfs = pcall(require,"cqueues")
    if cqueues then
        return
    end

    return 
end

