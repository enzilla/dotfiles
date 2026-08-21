#!/usr/bin/env bash
# Instala o graphify e o registra nos agentes, em uma máquina nova.
#
#   ~/.graphify/bootstrap.sh            instala CLI + integrações + MCP
#   ~/.graphify/bootstrap.sh --somente-cli
#
# Idempotente: pode rodar de novo para atualizar. Depois disso,
# ~/.graphify/refresh.sh constrói os grafos.
set -uo pipefail

PACOTE='graphifyy[sql,mcp]'
SOMENTE_CLI=""
[ "${1:-}" = "--somente-cli" ] && SOMENTE_CLI=1

passo() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }
ok()    { printf '    ok  %s\n' "$1"; }
aviso() { printf '    !!  %s\n' "$1" >&2; }

passo "CLI"
if command -v uv >/dev/null 2>&1; then
    uv tool install --quiet "$PACOTE" 2>/dev/null || uv tool upgrade --quiet graphifyy 2>/dev/null
elif command -v pipx >/dev/null 2>&1; then
    pipx install "$PACOTE" 2>/dev/null || pipx upgrade graphifyy
else
    aviso "instale uv (https://astral.sh/uv) ou pipx antes de continuar"
    exit 1
fi
command -v graphify >/dev/null 2>&1 || {
    aviso "graphify não caiu no PATH — rode 'uv tool update-shell' e abra um shell novo"
    exit 1
}
ok "$(graphify --version)"

[ -n "$SOMENTE_CLI" ] && exit 0

# O instalador do Claude Code grava em ~/.claude/CLAUDE.md, que aqui é um link
# para o dotfiles. Se o alvo não existir o link fica quebrado, então garantimos
# o arquivo antes.
alvo_claude=$(readlink -f "$HOME/.claude/CLAUDE.md" 2>/dev/null || true)
if [ -n "$alvo_claude" ] && [ ! -e "$alvo_claude" ]; then
    mkdir -p "$(dirname "$alvo_claude")" && : > "$alvo_claude"
    ok "criado $alvo_claude (link estava quebrado)"
fi

passo "Integrações com agentes"
# `graphify <plataforma> install` instala no ESCOPO DO PROJETO (cwd). Para o
# escopo de usuário é `graphify install --platform <plataforma>`, e ele precisa
# rodar fora de um repositório para não gravar CLAUDE.md/.claude no projeto.
cd "$HOME" || exit 1
for plataforma in claude opencode pi; do
    if saida=$(graphify install --platform "$plataforma" 2>&1); then
        ok "$plataforma"
    else
        aviso "$plataforma falhou: $(printf '%s' "$saida" | tail -1)"
    fi
done

# O instalador do opencode grava o plugin em ./.opencode/ relativo ao cwd.
# Movemos para o diretório global de plugins (versionado no dotfiles), de onde
# o opencode carrega automaticamente.
if [ -f "$HOME/.opencode/plugins/graphify.js" ]; then
    mkdir -p "$HOME/.config/opencode/plugins"
    mv -f "$HOME/.opencode/plugins/graphify.js" "$HOME/.config/opencode/plugins/graphify.js"
    rmdir "$HOME/.opencode/plugins" 2>/dev/null
    rm -f "$HOME/.opencode/opencode.json"
    ok "plugin do opencode movido para ~/.config/opencode/plugins/"
fi

passo "Servidor MCP"
GRAFO_GLOBAL="$HOME/.graphify/global-graph.json"
if command -v claude >/dev/null 2>&1; then
    if claude mcp list 2>/dev/null | grep -q '^graphify:'; then
        ok "já registrado"
    elif claude mcp add --scope user graphify -- graphify-mcp "$GRAFO_GLOBAL" >/dev/null 2>&1; then
        ok "registrado no escopo de usuário, servindo o grafo global"
    else
        aviso "registre à mão: claude mcp add --scope user graphify -- graphify-mcp $GRAFO_GLOBAL"
    fi
else
    aviso "CLI do claude ausente; registre depois"
fi

passo "Próximo passo"
echo "    ~/.graphify/refresh.sh        # constrói os grafos (alguns minutos)"
echo "    ~/.graphify/quem-usa.py       # consulta cruzada entre repositórios"
