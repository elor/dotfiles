
function __tmux_new_session
    if test -n "$TMUX"
        echo "Cannot open tmux session from inside tmux"
    else
        tmux new-session -t 0
    end
end

bind \cn '__tmux_new_session'

