local term = require("color-sync.terminal")

local group = vim.api.nvim_create_augroup("ColorSync", {})

local live_update_defer = nil
local save_defer = nil
local start_handle = nil
local function register(colorscheme)
    vim.schedule(function()
        local terminal = term.get()
        if terminal then
            local terminal_colorscheme = terminal:get_colorscheme(colorscheme)
            if vim.v.vim_did_enter == 1 then
                if live_update_defer ~= nil then live_update_defer:stop() end
                if save_defer ~= nil then save_defer:stop() end
                live_update_defer = vim.defer_fn(function() terminal:live_update(terminal_colorscheme) end, 400)
                save_defer = vim.defer_fn(function() terminal:save(terminal_colorscheme) end, 800)
            else
                if start_handle ~= nil then vim.api.nvim_del_autocmd(start_handle) end
                start_handle = vim.api.nvim_create_autocmd("VimEnter", {
                    once = true,
                    group = group,
                    callback = function()
                        terminal:live_update(terminal_colorscheme)
                        terminal:save(terminal_colorscheme)
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
