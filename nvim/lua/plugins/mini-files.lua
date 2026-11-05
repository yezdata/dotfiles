return {
    "echasnovski/mini.files",
    version = false,
    config = function()
        local git_file_cache = {}
        local git_dir_cache = {}
        local is_fetching = false

        local ignore_map = {
            [".DS_Store"] = true,
        }

        vim.api.nvim_set_hl(0, "MiniFilesGitModified", { fg = "#e2c08d", bold = false })
        vim.api.nvim_set_hl(0, "MiniFilesGitUntracked", { fg = "#73c991", bold = false })
        vim.api.nvim_set_hl(0, "MiniFilesGitAdded", { fg = "#73c991", bold = false })
        vim.api.nvim_set_hl(0, "MiniFilesGitDeleted", { fg = "#c74e39", strikethrough = true })

        local function get_hl_for_status(status)
            if not status then return nil end
            if status:match("%?") then
                return "MiniFilesGitUntracked"
            elseif status:match("A") then
                return "MiniFilesGitAdded"
            elseif status:match("M") then
                return "MiniFilesGitModified"
            elseif status:match("D") then
                return "MiniFilesGitDeleted"
            end
            return nil
        end

        local function update_git_status()
            if is_fetching then return end
            is_fetching = true

            vim.system(
                { "git", "rev-parse", "--show-toplevel" },
                { text = true },
                function(root_obj)
                    if root_obj.code ~= 0 or not root_obj.stdout then
                        is_fetching = false
                        return
                    end

                    local raw_root = vim.trim(root_obj.stdout)
                    local repo_root = vim.fs.normalize(raw_root)

                    vim.system(
                        { "git", "status", "--porcelain", "-uall" },
                        { text = true, cwd = repo_root },
                        function(status_obj)
                            is_fetching = false
                            if status_obj.code ~= 0 or not status_obj.stdout then
                                return
                            end

                            local new_file_cache = {}
                            local new_dir_cache = {}

                            for line in status_obj.stdout:gmatch("[^\r\n]+") do
                                local status = line:sub(1, 2)
                                local rel_path = line:sub(4)
                                if status:match("^R") then
                                    rel_path = rel_path:match("%->%s*(.*)$") or rel_path
                                end

                                local clean_rel = vim.trim(rel_path):gsub("/+$", "")
                                local abs_path = vim.fs.normalize(repo_root .. "/" .. clean_rel)
                                new_file_cache[abs_path] = status

                                local current_dir = vim.fs.dirname(abs_path)
                                while current_dir and #current_dir >= #repo_root do
                                    current_dir = vim.fs.normalize(current_dir)
                                    if not new_dir_cache[current_dir] or status:match("M") then
                                        new_dir_cache[current_dir] = status
                                    end
                                    local parent = vim.fs.dirname(current_dir)
                                    if parent == current_dir then break end
                                    current_dir = parent
                                end
                            end

                            git_file_cache = new_file_cache
                            git_dir_cache = new_dir_cache

                            vim.schedule(function()
                                if pcall(require, "mini.files") and require("mini.files").get_explorer_state() then
                                    pcall(require("mini.files").refresh)
                                end
                            end)
                        end
                    )
                end
            )
        end

        vim.api.nvim_create_autocmd("VimEnter", {
            callback = update_git_status,
        })

        vim.api.nvim_create_autocmd("BufWritePost", {
            callback = update_git_status,
        })

        vim.api.nvim_create_autocmd({ "FocusGained", "User" }, {
            pattern = { "", "MiniFilesExplorerOpen" },
            callback = update_git_status,
        })

        update_git_status()

        require("mini.files").setup({
            windows = {
                preview = true,
                width_preview = 55,
            },
            content = {
                filter = function(fs_entry)
                    return not ignore_map[fs_entry.name]
                end,
                prefix = function(fs_entry)
                    return require("mini.files").default_prefix(fs_entry)
                end,
                highlight = function(fs_entry)
                    local norm_path = vim.fs.normalize(fs_entry.path)
                    local status = nil

                    if fs_entry.fs_type == "directory" then
                        status = git_dir_cache[norm_path]
                    else
                        status = git_file_cache[norm_path]
                    end

                    local git_hl = get_hl_for_status(status)
                    if git_hl then
                        return git_hl
                    end

                    return require("mini.files").default_highlight(fs_entry)
                end,
            },
        })
    end,
}
