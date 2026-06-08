function remux
    ssh $argv[1] -t 'TERM=xterm-256color tmux new-window -s erik || xterm-256color tmux new-session -t erik'
end
