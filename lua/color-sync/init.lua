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

    local function colorscheme_into_terminal(colorscheme)
        return type(wezterm_colorschemes[colorscheme]) == "string" and wezterm_colorschemes[colorscheme] or colorscheme
    end

    local colorscheme = nil
    local function write_save()
        local save = colorscheme_into_terminal(colorscheme ~= nil and colorscheme or vim.g.colors_name) or ""
        vim.fn.writefile({ save }, wezterm .. "/generated_neovim_colorscheme", "")
        vim.notify("Setting WezTerm colorscheme to " .. save, vim.log.levels.INFO)
    end
    local function request_save()
        if vim.v.vim_did_enter == 1 then
            write_save()
        else
            vim.api.nvim_create_autocmd("VimEnter", {
                once = true,
                group = group,
                callback = function() write_save() end
            })
        end
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function(args)
            colorscheme = args.match
            request_save()
        end
    })

    write_save()
end

return M
