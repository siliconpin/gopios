set fish_greeting
set -x SHELL /usr/bin/fish

set -xU MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -xU MANROFFOPT "-c"
alias grep 'ugrep --color=auto'
alias egrep 'ugrep -E --color=auto'
alias fgrep 'ugrep -F --color=auto'
alias tarnow 'tar -acf '
alias untar 'tar -zxvf '
alias ls 'eza -al --color=always --group-directories-first --icons'
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'

if status --is-interactive && type -q fastfetch
   fastfetch --config puti.jsonc
end