# no prepend-path since we're running old fish versions on some workstations :-(
set PATH ~/.local/bin ~/.cargo/bin /sbin $PATH

if [ -d ~/.cabal/bin ]
  set PATH ~/.cabal/bin $PATH
end

which thefuck &>/dev/null && thefuck --alias | source

# ssh aliases
function ssk; ssh enssim $argv; end
function ssm; ssh mainsim $argv; end
function sst; ssh mainsimts1 $argv; end
function ssw; ssh mainsimweb $argv; end
function ssp; ssh simpc17 $argv; end
function sslm; ssh localmainsim $argv; end

alias lg=lazygit

function explorer; explorer.exe $argv; end
set DISPLAY :0.0

set TZ Europe/Berlin

set -g fish_greeting

function fisher_setup
  if not functions -q fisher
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
  end
  fisher install jorgebucaran/fisher
  fisher install jorgebucaran/autopair.fish
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
    eval /opt/homebrew/anaconda3/bin/conda "shell.fish" "hook" $argv | source
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
  function ls; lsd $argv; end
  function ll; lsd -l $argv; end
  function la; lsd -la $argv; end
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

setenv LC_CTYPE en_US.UTF-8
