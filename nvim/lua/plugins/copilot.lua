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
                        accept = "<M-l>",
                        accept_word = false,
                        accept_line = false,
                        next = "<M-n>",
                        prev = "<M-p>",
                        dismiss = "<M-e>",
                    },
                },
            })
        end,
    },
}
