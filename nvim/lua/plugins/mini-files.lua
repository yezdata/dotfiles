return {
    "echasnovski/mini.files",
    version = false,
    config = function()
        local ignore_map = {
            ['.DS_Store'] = true,
        }

        require("mini.files").setup({
            windows = {
                preview = true,
                width_preview = 55,
            },
            content = {
                filter = function(fs_entry)
                    return not ignore_map[fs_entry.name]
                end,
            },
        })
    end,
}
