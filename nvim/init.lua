local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("vim-options")
require("keymaps")
require("lazy").setup("plugins")


local stripper = require("comment_stripper")

vim.api.nvim_create_user_command("StripComments", stripper.strip_comments, {
    range = true,
    desc = "Strip all comments in range using Tree-sitter"
})


vim.api.nvim_create_user_command("ElStripper", stripper.rm_comments, {
    desc = "Strip comments in current file",
    range = false,
    nargs = 0,
})
