return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "bwpge/lualine-pretty-path",
    },
    event = "VimEnter",
    config = function()
        require("lualine").setup({
            options = {
                theme = 'tokyonight-night',
                -- section_separators = { left = "", right = "" },
                section_separators = "",
                component_separators = "|",
            },
            sections = {
                lualine_a = {
                    {
                        "mode",
                        fmt = function(str)
                            return str:sub(1, 1)
                        end,
                    },
                },
                lualine_c = {
                    {
                        "pretty_path",
                    },
                },
                lualine_x = {
                    -- "encoding",
                    { "fileformat", symbols = { unix = "" } },
                    -- { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 }},
                },
            },
            inactive_sections = {
                lualine_c = {
                    {
                        "pretty_path",
                        icon_show_inactive = true,
                    },
                },
            },
        })
    end,
}
