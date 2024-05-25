local colorschemes = {
    -- https://github.com/EdenEast/nightfox.nvim
    ["carbonfox"]        = { wezterm = true },
    ["dawnfox"]          = { wezterm = true },
    ["dayfox"]           = { wezterm = true },
    ["duskfox"]          = { wezterm = true },
    ["nightfox"]         = { wezterm = true },
    ["nordfox"]          = { wezterm = true },
    ["terafox"]          = { wezterm = true },

    -- https://github.com/folke/tokyonight.nvim
    -- ["tokyonight"] must evaluate which is currently used
    ["tokyonight-day"]   = { wezterm = "Tokyo Night Day" },
    ["tokyonight-moon"]  = { wezterm = "Tokyo Night Moon" },
    ["tokyonight-night"] = { wezterm = "Tokyo Night" },
    ["tokyonight-storm"] = { wezterm = "Tokyo Night Storm" },

    -- https://github.com/nyoom-engineering/oxocarbon.nvim
    ["oxocarbon"]        = { wezterm = "Oxocarbon Dark (Gogh)" },

    -- https://github.com/rose-pine/neovim
    ["rose-pine"]        = { wezterm = true },
    ["rose-pine-dawn"]   = { wezterm = true },
    ["rose-pine-main"]   = "rose-pine",
    ["rose-pine-moon"]   = { wezterm = true }
}

return {
    convert = function(colorscheme, terminal)
        local effective_colorscheme
        local terminal_colorschemes = colorschemes[colorscheme]
        while type(terminal_colorschemes) == "string" do
            effective_colorscheme = terminal_colorschemes
            terminal_colorschemes = colorschemes[effective_colorscheme]
        end

        local terminal_colorscheme = terminal_colorschemes and terminal_colorschemes[terminal.id] or nil
        return terminal_colorscheme == true and (effective_colorscheme or colorscheme) or terminal_colorscheme
    end
}
