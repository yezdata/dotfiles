return {
    "yetone/avante.nvim",
    build = vim.fn.has("win32") ~= 0
        and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        or "make",
    event = "VeryLazy",
    -- version = false, -- Never set this value to "*"! Never!
    version = "v0.1.1",
    ---@module 'avante'
    ---@type avante.Config
    opts = {
        mode = "legacy",
        provider = "copilot",
        behaviour = {
            auto_suggestions = false,
            auto_set_highlight_group = true,
            auto_set_keymaps = true,
            auto_apply_diff_after_generation = false,
            support_paste_from_clipboard = false,
            minimize_diff = true,
        },
        mappings = {
            diff = {
                ours = "co",
                theirs = "ct",
                all_theirs = "ca",
                both = "cb",
                cursor = "cc",
                next = "]x",
                prev = "[x",
            },
            submit = {
                normal = "<CR>",
                insert = "<C-s>",
            },
            sidebar = {
                apply_all = "A",
                apply_cursor = "a",
                switch_windows = "<Tab>",
                reverse_switch_windows = "<S-Tab>",
                close = { "<Esc>", "q" },
            },
        },
        windows = {
            position = "right",
            width = 30,
            sidebar_header = {
                align = "center",
                rounded = true,
            },
            input = {
                prefix = "> ",
                height = 8,
            },
            edit = {
                border = "rounded",
                start_insert = true,
            },
            ask = {
                floating = false,
                start_insert = true,
                border = "rounded",
            },
        },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
        "ibhagwan/fzf-lua",
        "zbirenbaum/copilot.lua",
        {
            "MeanderingProgrammer/render-markdown.nvim",
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
    },
}
