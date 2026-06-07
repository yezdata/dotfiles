return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  config = function()
    local npairs = require("nvim-autopairs")

    npairs.setup({
      check_ts = true, -- zapne integraci s Tree-sitterem
      disable_filetype = { "TelescopePrompt", "spectre_panel" },
    })
  end
}
