return {
    {
        "williamboman/mason.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "neovim/nvim-lspconfig",
            "williamboman/mason-lspconfig.nvim",
            "saghen/blink.cmp",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup()

            local capabilities = require('blink.cmp').get_lsp_capabilities()

            local function setup_server(server_name)
                local config = vim.lsp.config[server_name] or {}
                config.capabilities = vim.tbl_deep_extend("force", config.capabilities or {}, capabilities)

                if server_name == "pyright" then
                    config.on_init = function(client)
                        client.server_capabilities.documentFormattingProvider = false
                    end
                end

                vim.lsp.config(server_name, config)
                vim.lsp.enable(server_name)
            end

            -- Mason servers
            local installed_mason_servers = require("mason-lspconfig").get_installed_servers()
            for _, server in ipairs(installed_mason_servers) do
                setup_server(server)
            end

            -- Globally installed
            local system_servers = { "pyright", "ruff" }
            for _, server in ipairs(system_servers) do
                if not vim.tbl_contains(installed_mason_servers, server) and vim.fn.executable(server) == 1 then
                    setup_server(server)
                end
            end

            -- LspAttach
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
                    end

                    map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
                    map("n", "K", vim.lsp.buf.hover, "Show Documentation")
                    map("n", "gl", vim.diagnostic.open_float, "Show Error Details")
                    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Variable")
                    map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
                    map("n", "<leader>fr", function()
                        vim.lsp.buf.format({
                            async = true,
                            filter = function(client) return client.name ~= "pyright" end
                        })
                    end, "Format Code")
                end,
            })
        end,
    },
}
