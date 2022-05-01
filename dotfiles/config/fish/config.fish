set PATH ~/.local/bin ~/.cargo/bin /sbin $PATH

#thefuck --alias | source

function ssk; ssh enssim $argv; end
function ssm; ssh mainsim $argv; end
function sst; ssh mainsimts1 $argv; end
function ssw; ssh mainsimweb $argv; end
function ssp; ssh simpc17 $argv; end

function explorer; explorer.exe $argv; end
set DISPLAY :0.0

set TZ Europe/Berlin

set -g fish_greeting

function conda
  functions -e conda
  eval /beegfs-home/modules/conda/bin/conda "shell.fish" "hook" | source
  conda $argv
end

function spack
  functions -e spack
  source ~/spack/share/spack/setup-env.fish
  spack $argv
end

[ -s /opt/ohpc/admin/lmod/lmod/init/fish ] && source /opt/ohpc/admin/lmod/lmod/init/fish

function ls; lsd $argv; end
function ll; lsd -l $argv; end
function la; lsd -la $argv; end

function videokilledtheradiostar
  set url ( echo "$argv" | grep -o 'https://[^&]*' )
  while ! youtube-dl -F "$url"
    echo not yet
    sleep 30
  end
  mail -s 'Video killed the radio star' erik.e.lorenz@gmail.com < /dev/null
  exit
end

set LANG en_US.UTF8
