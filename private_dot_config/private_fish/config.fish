\if status is-interactive


    # Commands to run in interactive sessions can go here
end



alias sai='sudo apt install'
alias sau='sudo apt update'
alias sauu='sudo apt upgrade'
alias sar='sudo apt remove'
alias sas='sudo apt search'
alias ssh357='ssh cjs@100.72.181.118'
alias ff='fastfetch'
alias c='clear'
alias ..='cd ..'
alias ....='cd ../..'
alias fzf='fzf --preview="cat {}"'
alias bat='batcat'
alias chezcd="chezmoi cd"
alias chezedit='chezmoi edit'
alias chedit='chezmoi edit'
alias checd='chezmoi cd'
alias chapply='chezmoi apply'
starship init fish | source
zoxide init --cmd cd fish | source
# opencode
fish_add_path /home/charlie/.opencode/bin
