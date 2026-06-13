if which zoxide &>/dev/null
    zoxide init fish --cmd cd | source
    complete --command cd --keep-order --arguments '(__zoxide_cd_complete)'

    function __cd_aware_execute
        set -l tokens (commandline --tokenize)
        if commandline --paging-mode; and test "$tokens[1]" = cd
            commandline -f accept-autosuggestion execute
            return
        end
        __transient_execute
    end

    bind --user --mode default \r __cd_aware_execute
    bind --user --mode insert \r __cd_aware_execute
    bind --user --mode default \cj __cd_aware_execute
    bind --user --mode insert \cj __cd_aware_execute
end
alias z=cdi
