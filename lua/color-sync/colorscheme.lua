local colorschemes = {
    ["carbonfox"]  = { wezterm = true },
    ["duskfox"]    = { wezterm = true },
    ["tokyonight"] = { wezterm = "Tokyo Night" },
    ["oxocarbon"]  = { wezterm = "Oxocarbon Dark (Gogh)" },
    ["rose-pine"]  = { wezterm = true }
}

return {
    convert = function(colorscheme, terminal)
        local terminal_colorscheme = colorschemes[colorscheme][terminal.id]
        return terminal_colorscheme == true and colorscheme or terminal_colorscheme
    end
}
