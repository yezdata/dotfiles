return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        {
            "<leader>tt",
            "<cmd>TodoFzfLua<cr>",
            desc = "Todo (Fzf-Lua)",
        },
    },
    opts = {
    }
}
