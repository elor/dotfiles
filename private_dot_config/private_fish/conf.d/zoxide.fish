if which zoxide &>/dev/null
    zoxide init fish --cmd cd | source
    complete --command cd --keep-order --arguments '(__zoxide_cd_complete)'
end
alias z=cdi
