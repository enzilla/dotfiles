# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
unalias ga 2>/dev/null || true
# /etc/omarchy.conf is written by omarchy-dev-link. When absent, force the
# package default instead of preserving a stale inherited dev-link value before
# we decide which rc file to source.
if [[ -f /etc/omarchy.conf ]]; then
  source /etc/omarchy.conf
  export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
else
  export OMARCHY_PATH=/usr/share/omarchy
fi
source "$OMARCHY_PATH/default/bash/rc"

killport() {
  [ -z "$1" ] && { echo "uso: killport <porta> [sinal]" >&2; return 1; }
  local port="$1" sig="${2:-TERM}" pids
  pids=$(ss -tlnpH "sport = :$port" 2>/dev/null | grep -oP 'pid=\K[0-9]+' | sort -u)
  [ -z "$pids" ] && { echo "nada escutando na porta $port" >&2; return 1; }
  echo "matando PID(s) na porta $port: $pids (SIG$sig)"
  kill "-$sig" $pids
}

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

. <(asdf completion bash)
# Credenciais. Fora do repositório de dotfiles de propósito.
if [[ -f ~/.config/secrets.env ]]; then
  source ~/.config/secrets.env
fi
export NUMIH_GITHUB_USER="enzolazz"
export GOPRIVATE="github.com/numih/*"



export PUBSUB_EMULATOR_HOST=localhost:8681
export GOOGLE_CLOUD_PROJECT=numih-local

export GRAPHQL_COMPLEXITY_LIMIT=300
# Bash settings
set -o vi

shopt -s progcomp
shopt -s expand_aliases

# Docker

# Alias
alias dc='docker compose -f $HOME/docker/infra/compose/docker-compose.yml'
alias d='docker'
alias dl='echo $NUMIH_GITHUB_TOKEN | docker login ghcr.io -u $NUMIH_GITHUB_USER --password-stdin'
alias dr='rm -rf ~/docker |
  git clone https://github.com/Numih/dev-compose.git ~/docker '
alias dcp='dc pull --ignore-pull-failures'
alias dcr='docker rmi -f '
alias dgrep="d ps | grep"
alias dlog="d logs -f"

# Segue os logs do primeiro container cujo nome casa com o argumento
# Uso: dattach <nome-parcial>
dattach() {
  local id
  id=$(d ps --filter "name=$1" --format '{{.ID}}' | head -n1)
  if [ -z "$id" ]; then
    echo "Nenhum container em execução casa com \"$1\"." >&2
    return 1
  fi
  d logs -f "$id"
}

# Claude
alias cl="claude --dangerously-skip-permissions"
alias c="claude --dangerously-skip-permissions -p"

# Kubernetes
alias k='kubectl'


# Maven

alias m='mvn'
alias mci='mvn clean install'
alias mcis='mvn clean install -DskipTests'
alias mcp='mvn clean package'
alias mcps='mvn clean package -DskipTests'

# Dev

alias run-dev='mvn spring-boot:run -Dspring-boot.run.profiles=dev'
alias run-tests='mvn test -Dspring-boot.run.profiles=test'
alias debug-dev='run-dev -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000"'
alias debug-tests='run-tests -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000"'
alias java-17='sdk default java 17.0.4.fx-zulu'

# Misc
alias repo='cd $GITPOD_REPO_ROOT'

alias dtkt='detekt-cli -c ~/detekt-config/detekt-config.yml -ex "**/target/**"'

alias cc='rm -rf /home/gitpod/.m2/repository'

alias nm-aliases='message=$(cat ~/.bash_aliases | grep =) && echo "${message//alias /}"'

eval "$(zoxide init bash)"

# Completions

# Docker (usa _docker)
complete -o default -F _docker d
complete -o default -F _docker dc

# kubectl (usa __start_kubectl)
# note: se não existir, vamos source o completion direto abaixo
complete -o default -F __start_kubectl k

# Maven (usa _mvn)
complete -o default -F _mvn m
complete -o default -F _mvn mci
complete -o default -F _mvn mcis
complete -o default -F _mvn mcp
complete -o default -F _mvn mcps

# fallback: se alguma função não existir, source o arquivo de completion correspondente
# (não sobrescreve se já carregado)
if ! type _docker >/dev/null 2>&1 && [ -f /usr/share/bash-completion/completions/docker ]; then
  . /usr/share/bash-completion/completions/docker
fi

if ! type __start_kubectl >/dev/null 2>&1 && [ -f /usr/share/bash-completion/completions/kubectl ]; then
  . /usr/share/bash-completion/completions/kubectl
fi

if ! type _mvn >/dev/null 2>&1 && [ -f /usr/share/bash-completion/completions/mvn ]; then
  . /usr/share/bash-completion/completions/mvn
fi

# Git

# Load git completion if not already loaded
if ! type __git_complete >/dev/null 2>&1 && [ -f /usr/share/bash-completion/completions/git ]; then
  . /usr/share/bash-completion/completions/git
fi

alias g='git'
__git_complete g __git_main

alias gp='git fetch -p'
__git_complete gp _git_fetch

alias gs='git status'
__git_complete gs _git_status

alias ga='git add .'
__git_complete ga _git_add

alias gr='git restore .'
__git_complete gr _git_restore

alias gc='git commit -m'
__git_complete gc _git_commit

alias gch='git checkout'
__git_complete gch _git_checkout

alias gca='git commit -am'
__git_complete gca _git_commit

alias gpl='git pull'
__git_complete gpl _git_pull

alias gps='git push'
__git_complete gps _git_push

alias gbr='git branch'
__git_complete gbr _git_branch

gbrgone() {
  git fetch --prune

  local current_branch
  local gone_branches

  current_branch="$(git branch --show-current)"
  gone_branches="$(git branch --format='%(refname:short) %(upstream:track)' | awk -v current="$current_branch" '$2 == "[gone]" && $1 != current { print $1 }')"

  if [ -z "$gone_branches" ]; then
    echo "Nenhuma branch local com upstream remoto deletado."
    return 0
  fi

  printf '%s\n' "$gone_branches" | xargs -r git branch -d
}
__git_complete gbrgone _git_branch

alias gsw='git switch'
__git_complete gsw _git_switch

alias gst='git stash'
__git_complete gst _git_stash

alias gsa='git stash apply'
__git_complete gsa _git_stash

alias gsm='git stash merge'
__git_complete gsm _git_stash

alias gsd='git stash drop'
__git_complete gsd _git_stash

alias gsl='git stash list'
__git_complete gsl _git_stash

alias gsp='git stash pop'
__git_complete gsp _git_stash

alias gss='git stash show'
__git_complete gss _git_stash

# pnpm
export PNPM_HOME="/home/enzo/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


# clean queues
rabbitmq-clean-module-queues() {
  local module="${1:?uso: rabbitmq-clean-module-queues <modulo>}"
  local container="${RABBIT_CONTAINER:-$(docker ps --format '{{.Names}}' | rg -m1 'rabbit|mq')}"

  docker exec "$container" bash -lc "
    rabbitmqctl list_queues -p / name --silent | while IFS= read -r q; do
      case \"\$q\" in
        *$module*)
          echo \"Removendo fila: \$q\"
          rabbitmqctl delete_queue -p / \"\$q\"
          ;;
      esac
    done
  "
}

. "$HOME/.local/share/../bin/env"

# Pi
export PATH="/home/enzo/.local/share/pi-node/node-v22.23.0-linux-x64/bin:$PATH"

# FortiClient VPN
export FCT_VPN='Tasy - UMC'

# -p pede a senha. Testado: a senha salva pela GUI e apagada por um connect via
# CLI, e o -s do CLI nao persiste. Pedir sempre e a unica forma confiavel --
# sem isso da "Insufficient credential(s)".
alias vpnup='fortivpn connect "$FCT_VPN" -p'
alias vpndown='fortivpn disconnect'
alias vpnst='fortivpn status'
alias vpnls='fortivpn list'
alias vpned='fortivpn edit "$FCT_VPN"'

# O servidor do herdr sobe como serviço systemd fora da sessão gráfica, então
# seus panes herdam um ambiente sem WAYLAND_DISPLAY e wl-paste/wl-copy falham —
# é o que impedia colar imagem nos agentes. Descobre o socket em vez de fixar o
# número, que muda entre sessões.
if [[ -z $WAYLAND_DISPLAY && -n $XDG_RUNTIME_DIR ]]; then
  for _wl_sock in "$XDG_RUNTIME_DIR"/wayland-[0-9]*; do
    [[ -S $_wl_sock ]] || continue
    export WAYLAND_DISPLAY="${_wl_sock##*/}"
    break
  done
  unset _wl_sock
fi
