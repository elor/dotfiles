# no prepend-path since we're running old fish versions on some workstations :-(
set PATH ~/.local/bin ~/.cargo/bin /sbin $PATH

if [ -d ~/.cabal/bin ]
  set PATH ~/.cabal/bin $PATH
end

which thefuck &>/dev/null && thefuck --alias | source

function ssm; 
  if test -z $argv
    ssh mainsim -t fish
  else
    ssh mainsim $argv
  end
end

abbr sst ssh mainsimts1
abbr ssw ssh mainsimweb
abbr sslm ssh localmainsim

abbr lg lazygit
abbr gp git pull

function explorer; explorer.exe $argv; end
set DISPLAY :0.0

set TZ Europe/Berlin

set -g fish_greeting

function fisher_setup
  if not functions -q fisher
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
  end
  fisher install jorgebucaran/fisher
  fisher install acomagu/fish-async-prompt
  fisher install jbonjean/re-search
  fisher install jethrokuan/fzf
end

if [ -f /beegfs-home/modules/conda/bin/conda ]
  function conda
    functions -e conda
    eval /beegfs-home/modules/conda/bin/conda "shell.fish" "hook" | source
    conda $argv
  end
end

if [ -f /opt/homebrew/anaconda3/bin/conda ]
  function conda
    functions -e conda
    eval /opt/homebrew/anaconda3/bin/conda "shell.fish" "hook" | source
    functions -e fish_right_prompt
    conda $argv
  end
end

function spack
  functions -e spack
  source ~/spack/share/spack/setup-env.fish
  spack $argv
end

[ -s /opt/ohpc/admin/lmod/lmod/init/fish ] && source /opt/ohpc/admin/lmod/lmod/init/fish

if which lsd &>/dev/null
  abbr ls lsd
  abbr ll lsd -l
  abbr la lsd -la
end

set LANG en_US.UTF-8

which any-nix-shell &>/dev/null && any-nix-shell fish --info-right | source

set -U FZF_DEFAULT_OPTS "--preview 'string match -rq \"[\\\"\\'*]\" {} && exit 1; [ -d \"{}\" ] && lsd --color always \"{}\"; [ -f \"{}\" ] && bat --color always --line-range :50 \"{}\"; '"

if which nvim &>/dev/null
  setenv EDITOR (which nvim)
else if which vim &>/dev/null
  setenv EDITOR (which vim)
else
  setenv EDITOR (which nano)
end

abbr tre tree
abbr tls "tmux list-sessions"
abbr tns "tmux new-session -t 0"
abbr clg chezmoi git lazy
abbr cgl chezmoi git lazy

abbr sshpass "sshpass -f ~/.ssh/sshpass ssh"

abbr bubu "brew update && brew upgrade"

abbr gcs "gh copilot suggest -t shell"
abbr !! "gh copilot suggest -t shell"
abbr gce "gh copilot explain"

setenv LC_CTYPE en_US.UTF-8

if status --is-interactive
  setenv SHELL (which fish)
end
