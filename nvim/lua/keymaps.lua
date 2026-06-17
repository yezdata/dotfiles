vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Prevents space from moving the cursor in normal/visual mode
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { desc = "Disable Space default cursor action" })

vim.keymap.set("n", "<leader>s", function()
    pcall(function() vim.lsp.buf.format({ async = false }) end)
    vim.cmd("write")
end, { desc = "Format and save current file" })

vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { silent = true, desc = "Quit current window" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>u", require("undotree").open)

vim.keymap.set("n", '<C-w>"', ":split<CR>", { silent = true, desc = "Split window horizontally" })
vim.keymap.set("n", "<C-w>%", ":vsplit<CR>", { silent = true, desc = "Split window vertically" })
vim.keymap.set("n", "<C-t>", ":tabnew<CR>", { silent = true, desc = "Open a new tab page" })

vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true, desc = "Clear search highlighting" })

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal insert mode" })

vim.keymap.set("v", "<leader>y", '"+y', { desc = "Copy selection to system clipboard" })
vim.keymap.set("n", "<leader>y", '"+y', { desc = "Copy motion to system clipboard" })
vim.keymap.set("n", "<leader>yy", '"+yy', { desc = "Copy current line to system clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { desc = "Paste system clipboard after cursor" })
vim.keymap.set("n", "<leader>P", '"+P', { desc = "Paste system clipboard before cursor" })
vim.keymap.set("v", "<leader>p", '"+p', { desc = "Paste system clipboard over selection" })

local minifiles_toggle = function(...)
    if not MiniFiles.close() then
        MiniFiles.open(...)
    end
end
vim.keymap.set("n", "<leader>e", minifiles_toggle, { silent = true, desc = "Toggle mini.files explorer" })


local rm_comments = function()
    local current_file = vim.api.nvim_buf_get_name(0)

    if current_file == "" then
        vim.notify("Error: Current buffer is not a file on disk", vim.log.levels.ERROR)
        return
    end

    if vim.bo.modified then
        vim.cmd("silent write")
    end

    local home = os.getenv("HOME")
    local cmd = home .. "/.local/bin/el_stripper"
    local full_cmd = string.format("%s %s --doc", vim.fn.shellescape(cmd), vim.fn.shellescape(current_file))

    local output = vim.fn.system(full_cmd)
    local exit_code = vim.v.shell_error

    if exit_code == 0 then
        vim.cmd("checktime")
        local clean_output = vim.trim(output)
        local filename = vim.fn.fnamemodify(current_file, ":t")
        if clean_output ~= "" then
            vim.notify(clean_output, vim.log.levels.INFO)
        else
            vim.notify("[✓] Stripped comments and docstrings in " .. filename, vim.log.levels.INFO)
        end
    else
        vim.notify("Exit: code " .. exit_code .. "):\n" .. vim.trim(output), vim.log.levels.ERROR)
    end
end

vim.keymap.set('n', '<leader>rc', rm_comments)
