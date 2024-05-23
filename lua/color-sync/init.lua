local M = {}

function M.setup() end

local group = vim.api.nvim_create_augroup("ColorSync", {})

local wezterm = (vim.env.XDG_CONFIG_HOME or (assert(vim.env.HOME) .. "/.config")) .. "/wezterm"
if vim.fn.isdirectory(wezterm) then
    local wezterm_colorschemes = {
        ["carbonfox"] = true,
        ["duskfox"] = true,
        ["tokyonight"] = "Tokyo Night",
        ["oxocarbon"] = "Oxocarbon Dark (Gogh)",
        ["rose-pine"] = true
    }

    local colorscheme = nil
    local function terminal_colorscheme()
        local key = colorscheme ~= nil and colorscheme or vim.g.colors_name
        local value = wezterm_colorschemes[key]
        if value ~= nil then
            return type(value) == "string" and value or key
        end
    end
    local function save()
        local data = terminal_colorscheme() or ""
        vim.fn.writefile({ data }, wezterm .. "/generated_neovim_colorscheme", "")
        vim.notify("Setting WezTerm colorscheme to " .. data, vim.log.levels.INFO)
    end
    local save_attempt = nil
    local function register()
        if vim.v.vim_did_enter == 1 then
            vim.fn.chansend(vim.v.stderr,
                "\x1b]1337;SetUserVar=neovim_colorscheme=" ..
                vim.base64.encode(terminal_colorscheme() or "") .. "\x07")

            if save_attempt ~= nil then save_attempt:stop() end
            save_attempt = vim.defer_fn(save, 800)
        else
            vim.api.nvim_create_autocmd("VimEnter", {
                once = true,
                group = group,
                callback = register
            })
        end
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function(args)
            colorscheme = args.match
            register()
        end
    })

    register()
end

return M
