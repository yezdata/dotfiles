vim.diagnostic.config({
    virtual_text = {
        spacing = 8,
        source = "if_many",
        prefix = "■",
    },
    severity_sort = true,
    underline = true,
    update_in_insert = false,
})

vim.cmd("packadd nvim.undotree")

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.autoindent = true
vim.opt.smartindent = false -- Handled by LSP/Treesitter
vim.opt.smarttab = true

vim.opt.smoothscroll = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 10

vim.opt.splitright = true
vim.opt.showmode = false -- Lualine handles this
vim.opt.showcmd = true
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.shell = "fish"

-- Highlight briefly on yank (copy)
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Briefly highlight yanked text",
    callback = function()
        vim.highlight.on_yank({ on_visual = true })
    end,
})

-- Disable line numbers in built-in terminal mode
vim.api.nvim_create_autocmd("TermOpen", {
    desc = "Disable line numbers in terminal buffers",
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
    end,
})

-- Prevent Neovim from auto-commenting next line when hitting Enter on a commented line
vim.api.nvim_create_autocmd("FileType", {
    desc = "Disable automatic comment insertion on new lines",
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ 'r', 'o' })
    end,
})

vim.g.ts_auto_install = false
