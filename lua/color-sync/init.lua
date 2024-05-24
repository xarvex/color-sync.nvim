local M = {}

function M.setup() end

local group = vim.api.nvim_create_augroup("ColorSync", {})

local wezterm = (vim.env.XDG_CONFIG_HOME or (assert(vim.env.HOME) .. "/.config")) .. "/wezterm"
if vim.fn.isdirectory(wezterm) then
    local generated = wezterm .. "/generated"
    local wezterm_colorschemes = {
        ["carbonfox"] = true,
        ["duskfox"] = true,
        ["tokyonight"] = "Tokyo Night",
        ["oxocarbon"] = "Oxocarbon Dark (Gogh)",
        ["rose-pine"] = true
    }

    local function terminal_colorscheme(colorscheme)
        local key = colorscheme ~= nil and colorscheme or vim.g.colors_name
        local value = wezterm_colorschemes[key]
        if value ~= nil then
            return type(value) == "string" and value or key
        end
    end
    local function override(colorscheme)
        vim.fn.chansend(vim.v.stderr,
            "\x1b]1337;SetUserVar=neovim_colorscheme=" ..
            vim.base64.encode(terminal_colorscheme(colorscheme) or "") .. "\x07")
    end
    local function save(colorscheme)
        vim.fn.mkdir(generated, "p")
        local data = terminal_colorscheme(colorscheme) or ""
        vim.fn.writefile({ data }, generated .. "/neovim_colorscheme", "")
        vim.notify("Setting WezTerm colorscheme to " .. data, vim.log.levels.INFO)
    end
    local override_defer = nil
    local save_defer = nil
    local start_handle = nil
    local function register(colorscheme)
        if vim.v.vim_did_enter == 1 then
            if override_defer ~= nil then override_defer:stop() end
            if save_defer ~= nil then save_defer:stop() end
            override_defer = vim.defer_fn(function() override(colorscheme) end, 400)
            save_defer = vim.defer_fn(function() save(colorscheme) end, 800)
        else
            if start_handle ~= nil then vim.api.nvim_del_autocmd(start_handle) end
            start_handle = vim.api.nvim_create_autocmd("VimEnter", {
                once = true,
                group = group,
                callback = function()
                    override(colorscheme)
                    save(colorscheme)
                end
            })
        end
    end

    register(vim.g.colors_name)
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function(args) register(args.match) end
    })
end

return M
