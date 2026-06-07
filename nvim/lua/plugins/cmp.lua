return {
    {
        "saghen/blink.cmp",
        version = "v1.*",
        event = "InsertEnter",
        dependencies = { "rafamadriz/friendly-snippets" },
        opts = {
            snippets = {
                preset = "default",
            },

            keymap = {
                preset = "none",
                ["<C-b>"] = { "scroll_documentation_up", "fallback" },
                ["<C-f>"] = { "scroll_documentation_down", "fallback" },
                ["<C-n>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "hide", "fallback" },
                ["<CR>"] = { "accept", "fallback" },
                ["<Tab>"] = { "select_next", "fallback" },
                ["<S-Tab>"] = { "select_prev", "fallback" },
            },

            completion = {
                menu = {
                    border = "rounded",
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 0,
                    window = {
                        border = "rounded",
                    },
                },
            },

            signature = {
                enabled = true,
                window = {
                    border = "rounded",
                },
            },

            sources = {
                default = { "lsp", "snippets", "path", "buffer" },
                providers = {
                    lsp = { score_offset = 100 },
                    snippets = { score_offset = 75 },
                    path = {
                        score_offset = 50,
                        opts = {
                            trailing_slash = true,
                            label_trailing_slash = true,
                            get_cwd = function()
                                return vim.fn.getcwd()
                            end,
                        },
                    },
                    buffer = { score_offset = 25 },
                },
            },
        },
    },
}
