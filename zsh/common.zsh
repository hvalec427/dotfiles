# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# jenv
eval "$(jenv init -)"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

alias ls="eza"
alias ll="eza -la --icons --git --group-directories-first"
alias lt="eza --tree --level=2 --icons"
alias l="eza -1"

eval "$(zoxide init zsh)"
alias cd="z"

alias cat="bat"

# start tmux sessions scripts
alias tmuxz="~/.config/tmux/sessions/zigahvalec.sh"
alias tmuxlhc="~/.config/tmux/sessions/laundryheap-mobile.sh"
alias tmuxlhd="~/.config/tmux/sessions/laundryheapp-driverapp.sh"
alias tmuxlhr="~/.config/tmux/sessions/laundryheap-runners.sh"
alias tmuxdot="~/.config/tmux/sessions/dotfiles.sh"
alias lg="lazygit"
