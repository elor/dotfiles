function pyenv_init
    if which pyenv &>/dev/null
        pyenv init - | source
    end
end
