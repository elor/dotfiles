# no prepend-path since we're running old fish versions on some workstations :-(
set PATH ~/.local/bin ~/.cargo/bin /sbin $PATH

abbr lg lazygit

set TZ Europe/Berlin

set -g fish_greeting

function fisher_setup
    if not functions -q fisher
        curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    end
    fisher install jorgebucaran/fisher
    fisher install jbonjean/re-search
    fisher install jethrokuan/fzf
    fisher install zzhaolei/transient.fish
    fisher install gazorby/fifc
end

function conda
    functions -e conda
    if which conda &>/dev/null
        eval conda "shell.fish" hook | source
    else
        echo "No conda found"
        return
    end

    conda $argv
end

if which lsd &>/dev/null
    abbr ls lsd
    abbr ll lsd -l
    abbr la lsd -la
end

set LANG en_US.UTF-8

which any-nix-shell &>/dev/null && any-nix-shell fish --info-right | source

set -U FZF_DEFAULT_OPTS "--preview 'string match -rq \"[\\\"\\'*]\" {} && exit 1; [ -d \"{}\" ] && lsd --color always \"{}\"; [ -f \"{}\" ] && bat --color always --line-range :50 \"{}\"; '"

if which nvim &>/dev/null
    setenv EDITOR nvim
else if which vim &>/dev/null
    setenv EDITOR vim
else if which nano &>/dev/null
    setenv EDITOR nano
end
set -Ux fifc_editor "$EDITOR"

abbr tre tree
abbr clg chezmoi git lazy
abbr cgl chezmoi git lazy

abbr bubu "brew update && brew upgrade && brew upgrade --cask --greedy && brew cleanup"

abbr kssh "kitty +kitten ssh"

abbr tldl "tldr -p linux"

setenv LC_CTYPE en_US.UTF-8

if status --is-interactive
    setenv SHELL (which fish)
    bind \cZ z
end
