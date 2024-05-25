local convert_colorscheme = require("color-sync.colorscheme").convert
local get_terminal = require("color-sync.terminal").get

local group = vim.api.nvim_create_augroup("ColorSync", {})

local function live_update(terminal, terminal_colorscheme)
    terminal.live_update(terminal_colorscheme)
end
local function save(terminal, terminal_colorscheme)
    vim.notify("Setting " .. tostring(terminal) .. " colorscheme to " .. (terminal_colorscheme or ""),
        vim.log.levels.INFO)
    terminal.save(terminal_colorscheme)
end

local live_update_defer = nil
local save_defer = nil
local start_handle = nil
local function register(colorscheme)
    vim.schedule(function()
        local terminal = get_terminal()
        if terminal then
            local terminal_colorscheme = convert_colorscheme(colorscheme, terminal)
            if vim.v.vim_did_enter == 1 then
                if live_update_defer ~= nil then live_update_defer:stop() end
                if save_defer ~= nil then save_defer:stop() end
                live_update_defer = vim.defer_fn(function() live_update(terminal, terminal_colorscheme) end, 400)
                save_defer = vim.defer_fn(function() save(terminal, terminal_colorscheme) end, 800)
            else
                if start_handle ~= nil then vim.api.nvim_del_autocmd(start_handle) end
                start_handle = vim.api.nvim_create_autocmd("VimEnter", {
                    once = true,
                    group = group,
                    callback = function()
                        live_update(terminal, terminal_colorscheme)
                        save(terminal, terminal_colorscheme)
                    end
                })
            end
        end
    end)
end

register(vim.g.colors_name)
vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function(args) register(args.match) end
})

return { setup = function() end }
