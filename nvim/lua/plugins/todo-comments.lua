return {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        {
            "<leader>tt",
            "<cmd>TodoFzfLua<cr>",
            desc = "Todo (Fzf-Lua)",
        },
        {
            "<leader>tb",
            function()
                local keywords = vim.tbl_keys(require("todo-comments.config").options.keywords)
                local pattern = "\\b(" .. table.concat(keywords, "|") .. "):"
                require("fzf-lua").grep_curbuf({
                    search = pattern,
                    no_esc = true,
                })
            end,
            desc = "Todo (Current Buffer)",
        },
    },
    opts = {
    }
}
