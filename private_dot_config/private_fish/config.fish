if status is-interactive
    # Commands to run in interactive sessions can go here
end

if command -q paru
    alias get='paru -S'
    alias update='paru -Syu'
    alias remove='paru -Rs'
    alias search='paru -Ss'
else if command -q pacman
    alias get='sudo pacman -S'
    alias update='sudo pacman -Syu'
    alias remove='sudo pacman -Rs'
    alias search='pacman -Ss'
else if command -q zypper
    alias get='sudo zypper install --no-recommends'
    alias update='sudo zypper dup'
    alias remove='sudo zypper remove --clean-deps'
    alias search='zypper search'
else if command -q apt
    alias get='sudo apt install'
    alias update='sudo apt update && sudo apt upgrade'
    alias remove='sudo apt remove'
    alias search='apt search'
end

# bat — handle Ubuntu naming difference
if command -q batcat
    alias bat='batcat'
end

alias ssh357='ssh cjs@100.72.181.118'
alias ff='fastfetch'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias fzf='command fzf --preview="bat {}"'

# chezmoi
alias chcd='chezmoi cd'
alias chedit='chezmoi edit'
alias chapply='chezmoi apply'

starship init fish | source
zoxide init --cmd cd fish | source

# Patch _z_cd to use builtin cd, preventing infinite loop
function _z_cd
    builtin cd $argv
    or return $status
    commandline -f repaint
    if test "$_ZO_ECHO" = "1"
        echo $PWD
    end
end


# opencode
fish_add_path /home/charlie/.opencode/bin

# user paths
fish_add_path ~/bin
fish_add_path ~/.local/bin
fish_add_path ~/scripts

if command -q brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)
end
