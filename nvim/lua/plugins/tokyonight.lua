return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("tokyonight").setup({
            transparent = false,
            styles = {
                comments = { italic = true },
                keywords = { bold = true },
                conditionals = { bold = true },
                functions = { bold = true },
                sidebars = "transparent",
                floats = "transparent"
            },
            lualine_bold = true
        })
        vim.cmd.colorscheme "tokyonight-night"
    end,
}
