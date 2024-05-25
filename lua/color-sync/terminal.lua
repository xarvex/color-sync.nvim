local function new_terminal(id, name, live_update, save)
    local term = {
        id = id,
        name = name,
        live_update = live_update,
        save = function(terminal_colorscheme)
            save(terminal_colorscheme, vim.env.XDG_CONFIG_HOME or (assert(vim.env.HOME) .. "/.config"))
        end
    }
    setmetatable(term, { __tostring = function(t) return t.name end })
    return term
end

local terminal_process = {
    ["wezterm-gui"] = new_terminal("wezterm", "WezTerm", function(terminal_colorscheme)
        vim.fn.chansend(vim.v.stderr,
            "\x1b]1337;SetUserVar=neovim_colorscheme=" ..
            vim.base64.encode(terminal_colorscheme or "") .. "\x07")
    end, function(terminal_colorscheme, config_home)
        local dir = config_home .. "/wezterm/generated"
        vim.fn.mkdir(dir, "p")
        local data = terminal_colorscheme
        vim.fn.writefile({ data }, dir .. "/neovim_colorscheme", "")
    end)
}

local terminal = nil

return {
    get = function()
        if not terminal then
            local pid = vim.uv.os_getppid()
            while pid ~= 1 and terminal == nil do
                local proc = vim.api.nvim_get_proc(pid)
                if proc then
                    terminal = terminal_process[proc.name]
                    pid = proc.ppid
                else
                    break
                end
            end
        end

        return terminal
    end
}
