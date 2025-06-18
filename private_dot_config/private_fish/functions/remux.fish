function remux
    ssh $argv[1] -t 'tmux new-window -s erik || tmux new-session -t erik'
end
