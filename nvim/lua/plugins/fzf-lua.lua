return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local fzf = require("fzf-lua")
        fzf.setup({
            files = {
                cmd =
                "fd --type f --hidden --follow --exclude .DS_Store --exclude .git --exclude .venv --exclude __pycache__ --exclude *.egg-info",
            },
            grep = {
                rg_opts =
                "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden --glob '!.git/' --glob '!.DS_Store' --glob '!.venv' --glob '!*.egg-info' --e",
            },
            keymap = {
                fzf = {
                    ["ctrl-q"] = "select-all+accept",
                },
            },
        })

        vim.keymap.set("n", "<leader><leader>", fzf.files, { desc = "Najít soubory" })
        vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Hledat text v souborech" })
        vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Přepnout buffer" })
        vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "Nápověda" })

        vim.keymap.set("n", "<leader>fd", fzf.diagnostics_document, { desc = "LSP chyby (aktuální soubor)" })
        vim.keymap.set("n", "<leader>fD", fzf.diagnostics_workspace, { desc = "LSP chyby (projekt)" })

        fzf.register_ui_select()
    end,
}
