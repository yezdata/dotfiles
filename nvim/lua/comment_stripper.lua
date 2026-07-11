local M = {}

function M.rm_comments()
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
        vim.cmd("silent edit!")

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

-- visual mode universal comment strip
function M.strip_comments(opts)
    local start_line, end_line
    if opts.range == 2 then
        start_line = vim.fn.line("'<") - 1
        end_line = vim.fn.line("'>")
    else
        start_line = 0
        end_line = vim.api.nvim_buf_line_count(0)
    end

    local bufnr = 0

    local language = vim.bo[bufnr].filetype
    if language == "" then return end

    local has_parser, parser = pcall(vim.treesitter.get_parser, bufnr, language)
    if not has_parser or not parser then
        vim.notify("Tree-sitter parser for '" .. language .. "' is not available", vim.log.levels.WARN)
        return
    end

    local tree = parser:parse({ start_line, end_line })[1]
    local root = tree:root()

    local query_str = "((comment) @comment)"

    local has_query, query = pcall(vim.treesitter.query.parse, language, query_str)
    if not has_query then
        vim.notify("Could not build Tree-sitter query for lang" .. language, vim.log.levels.ERROR)
        return
    end

    local edits = {}

    for id, node, _ in query:iter_captures(root, bufnr, start_line, end_line) do
        local capture_name = query.captures[id]
        local s_row, s_col, e_row, e_col = node:range()

        if s_row >= start_line and s_row < end_line then
            if capture_name == "comment" then
                table.insert(edits, { s_row = s_row, s_col = s_col, e_row = e_row, e_col = e_col })
            end
        end
    end

    table.sort(edits, function(a, b)
        if a.s_row ~= b.s_row then return a.s_row > b.s_row end
        return a.s_col > b.s_col
    end)

    for _, edit in ipairs(edits) do
        local line = vim.api.nvim_buf_get_lines(bufnr, edit.s_row, edit.s_row + 1, false)[1] or ""

        local before_comment = line:sub(1, edit.s_col)

        if before_comment:match("^%s*$") then
            vim.api.nvim_buf_set_lines(bufnr, edit.s_row, edit.s_row + 1, false, {})
        else
            local new_line = before_comment:gsub("%s+$", "")
            vim.api.nvim_buf_set_lines(bufnr, edit.s_row, edit.s_row + 1, false, { new_line })
        end
    end
end

return M
