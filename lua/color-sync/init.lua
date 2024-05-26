local group = vim.api.nvim_create_augroup("ColorSync", {})

local start_handle = nil
local function register(colorscheme)
    local terminal = require("color-sync.terminal").get()
    if terminal then
        local terminal_colorscheme = terminal:get_colorscheme(colorscheme)
        if vim.v.vim_did_enter == 1 then
            terminal:defer_live_update(terminal_colorscheme)
            terminal:defer_save(terminal_colorscheme)
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
end

vim.schedule(function()
    register(vim.g.colors_name)
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function(args) register(args.match) end
    })
end)

return { setup = function() end }
