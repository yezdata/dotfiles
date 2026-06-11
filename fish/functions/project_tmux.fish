function project_tmux --description "Open project from ~/projects in tmuxu with nvim and shell"
    set -l target_dir (fd --type d --min-depth 2 --max-depth 2 . ~/projects | fzf --prompt="project: " --height=40% --reverse)

    if test -z "$target_dir"
        return
    end

    set -l session_name (basename $target_dir | string replace -a '.' '_')

    if not tmux has-session -t $session_name 2>/dev/null
        set -l venv_cmd "test -f .venv/bin/activate.fish && source .venv/bin/activate.fish"

        tmux new-session -d -s $session_name -n "nvim" -c $target_dir "fish -i -c 'test -f .venv/bin/activate.fish && source .venv/bin/activate.fish; nvim; exec fish'"
        
        tmux new-window -t $session_name:2 -n "shell" -c $target_dir "fish -i -c 'test -f .venv/bin/activate.fish && source .venv/bin/activate.fish; exec fish'"
        
        tmux select-window -t $session_name:1
    end

    if test -n "$TMUX"
        tmux switch-client -t $session_name
    else
        tmux attach-session -t $session_name
    end
end
