# this is to handle jumping to commong paths
typeset -A JUMP_PATHS
JUMP_PATHS=(
  dev "$HOME/dev"
  dot "$HOME/dev/dotfiles"
  dotfiles "$HOME/dev/dotfiles"
  hvalec "$HOME/dev/zigahvalec"
  .config "$HOME/.config/"
)

jump() {
  if [[ $# -eq 0 ]]; then
    cd "$HOME" || return
    return
  fi

  case "$1" in
    -h|--help)
      printf 'Available jump targets:\n'
      for key in "${(@k)JUMP_PATHS}"; do
        printf '  %s -> %s\n' "$key" "${JUMP_PATHS[$key]}"
      done
      return
      ;;
  esac

  local dest="${JUMP_PATHS[$1]}"
  if [[ -n $dest ]]; then
    cd "$dest" || return
    return
  fi

  cd "$HOME/$1" || {
    printf 'jump: target "%s" not found\n' "$1" >&2
    return 1
  }
}

# this section just get's added to zshrc

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
alias tmuxz="~/dev/dotfiles/tmux/sessions/zigahvalec.sh"
