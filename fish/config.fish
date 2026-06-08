set -gx EDITOR nvim


if status is-interactive

  # function fish_greeting
  #   echo ""
  # end

  function fish_greeting
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        onefetch
        end
    end

  function fish_user_key_bindings
    bind \cg 'project_tmux; commandline -f repaint'
  end

  zoxide init --cmd cd fish | source
  starship init fish | source

  alias avante 'nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'
  alias ls 'eza --color=always --all --grid --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --group-directories-first --ignore-glob ".DS_Store|__pycache__|*.egg-info|*cache"'
  alias lst 'eza --color=always --all --tree --long --git --no-filesize --icons=always --no-time --no-user --no-permissions --group-directories-first --ignore-glob ".DS_Store|__pycache__|.git|*.egg-info|.venv|*cache"'

  abbr -a lzg lazygit
end
