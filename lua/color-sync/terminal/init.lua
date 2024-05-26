local get_terminal_colorscheme = require("color-sync.terminal.colorscheme").get

local function new_terminal(id, name, live_update, save)
    local term = {
        id = id,
        name = name,
        live_update = function(_, terminal_colorscheme)
            live_update.callback(terminal_colorscheme)
        end,
        live_update_timeout = live_update.timeout,
        defer_live_update = function(self, terminal_colorscheme)
            if self.live_update_defer ~= nil then self.live_update_defer:stop() end
            self.live_update_defer = vim.defer_fn(function() self:live_update(terminal_colorscheme) end,
                self.live_update_timeout)
        end,
        save = function(self, terminal_colorscheme)
            vim.notify("Setting " .. tostring(self) .. " colorscheme to " .. (terminal_colorscheme or ""),
                vim.log.levels.INFO)
            save.callback(terminal_colorscheme, vim.env.XDG_CONFIG_HOME or (assert(vim.env.HOME) .. "/.config"))
        end,
        save_timeout = save.timeout,
        defer_save = function(self, terminal_colorscheme)
            if self.save_defer ~= nil then self.save_defer:stop() end
            self.save_defer = vim.defer_fn(function() self:save(terminal_colorscheme) end, self.save_timeout)
        end,
        get_colorscheme = function(self, colorscheme)
            return get_terminal_colorscheme(colorscheme, self)
        end
    }
    setmetatable(term, { __tostring = function(t) return t.name end })
    return term
end

local terminal_process = {
    ["wezterm-gui"] = new_terminal("wezterm", "WezTerm", {
        callback = function(terminal_colorscheme)
            vim.fn.chansend(vim.v.stderr,
                "\x1b]1337;SetUserVar=neovim_colorscheme=" ..
                vim.base64.encode(terminal_colorscheme or "") .. "\x07")
        end,
        timeout = 0
    }, {
        callback = function(terminal_colorscheme, config_home)
            local dir = config_home .. "/wezterm/generated"
            vim.fn.mkdir(dir, "p")
            local data = terminal_colorscheme
            vim.fn.writefile({ data }, dir .. "/neovim_colorscheme", "")
        end,
        timeout = 800
    })
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
