return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                panel = { enabled = false },
                server_opts_overrides = {
                    settings = {
                        telemetry = {
                            telemetryLevel = "off",
                        },
                    },
                },
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    debounce = 75,
                    keymap = {
                        -- suggest = "<M-n>",
                        accept = "<Up>",
                        accept_word = false,
                        accept_line = false,
                        next = "<Down>",
                        -- prev = "<Up>",
                        dismiss = "<M-C-e>",
                    },
                },
            })
        end,
    },
}
