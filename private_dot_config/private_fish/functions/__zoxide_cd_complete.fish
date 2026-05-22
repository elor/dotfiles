function __zoxide_cd_complete
    set -l tokens (commandline --cut-at-cursor --current-process --tokenize)
    set -l args $tokens[2..]

    # For path-like inputs, return nothing and let fish's native directory completion handle it
    if test (count $args) -eq 1
        if string match -qr '^[/~.]' -- $args[1]
            return
        end
    end

    zoxide query --list --score --exclude (__zoxide_pwd) -- $args 2>/dev/null \
        | awk '{printf "%s\tfreq: %.0f\n", $2, $1}'
end
