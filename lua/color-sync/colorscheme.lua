local colorschemes = {
    ["carbonfox"]  = { wezterm = true },
    ["duskfox"]    = { wezterm = true },
    ["tokyonight"] = { wezterm = "Tokyo Night" },
    ["oxocarbon"]  = { wezterm = "Oxocarbon Dark (Gogh)" },
    ["rose-pine"]  = { wezterm = true }
}

return {
    convert = function(colorscheme, terminal)
        local terminal_colorschemes = colorschemes[colorscheme]
        local terminal_colorscheme = terminal_colorschemes and terminal_colorschemes[terminal.id] or nil
        return terminal_colorscheme == true and colorscheme or terminal_colorscheme
    end
}
