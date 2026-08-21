#!/usr/bin/env bash
# Reindexa os repositórios listados em ~/.graphify/repos.conf e recompõe o grafo
# global, sem gravar nada dentro das árvores de git.
#
#   refresh.sh                 todos os repositórios (incremental, usa cache)
#   refresh.sh apoio auth      só os repositórios nomeados
#   refresh.sh --force         ignora o cache e reextrai tudo
#   refresh.sh --descobrir     imprime os repositórios Numih encontrados em $GRAPHIFY_DEV
#
# Variáveis: GRAPHIFY_DEV (padrão ~/dev), GRAPHIFY_JOBS (padrão 8)
set -uo pipefail

BASE="${HOME}/.graphify"
OUT="${BASE}/out"
CONF="${BASE}/repos.conf"
DEV="${GRAPHIFY_DEV:-${HOME}/dev}"
JOBS="${GRAPHIFY_JOBS:-8}"
FORCE=""

if ! command -v graphify >/dev/null 2>&1; then
    echo "graphify não está no PATH — rode ~/.graphify/bootstrap.sh" >&2
    exit 1
fi

if [ "${1:-}" = "--descobrir" ]; then
    find "$DEV" -maxdepth 4 -name .git 2>/dev/null | while read -r g; do
        d=$(dirname "$g")
        u=$(git -C "$d" remote get-url origin 2>/dev/null) || continue
        case "$u" in *[Nn]umih*) ;; *) continue ;; esac
        case "$d" in *.worktrees*|*-wt-*) continue ;; esac
        printf '%s\n' "${d#"$DEV"/}"
    done | sort
    exit 0
fi

args=()
for a in "$@"; do
    case "$a" in
        --force) FORCE="--force" ;;
        -*) echo "opção desconhecida: $a" >&2; exit 2 ;;
        *) args+=("$a") ;;
    esac
done

[ -f "$CONF" ] || { echo "lista de repositórios não encontrada: $CONF" >&2; exit 1; }
mapfile -t todos < <(grep -vE '^\s*(#|$)' "$CONF")

alvos=()
if [ "${#args[@]}" -gt 0 ]; then
    for nome in "${args[@]}"; do
        achou=""
        for r in "${todos[@]}"; do
            [ "$(basename "$r")" = "$nome" ] && { alvos+=("$r"); achou=1; }
        done
        [ -n "$achou" ] || echo "aviso: '$nome' não está em repos.conf, ignorado" >&2
    done
else
    alvos=("${todos[@]}")
fi
[ "${#alvos[@]}" -gt 0 ] || { echo "nada a fazer" >&2; exit 1; }

mkdir -p "$OUT"
total="${#alvos[@]}"; n=0; falhas=0
inicio=$SECONDS

for rel in "${alvos[@]}"; do
    n=$((n + 1))
    tag=$(basename "$rel")
    caminho="$DEV/$rel"
    if [ ! -d "$caminho" ]; then
        echo "[$n/$total] $tag — ausente em $caminho, pulando" >&2
        continue
    fi
    printf '[%d/%d] %s ... ' "$n" "$total" "$tag"
    if saida=$(timeout 900 graphify extract "$caminho" --code-only \
                   --max-workers "$JOBS" --out "$OUT/$tag" \
                   --global --as "$tag" $FORCE 2>&1); then
        printf '%s\n' "$(printf '%s' "$saida" | grep -oE '[0-9]+ nodes, [0-9]+ edges' | tail -1)"
    else
        printf 'FALHOU\n'
        printf '%s\n' "$saida" | tail -3 >&2
        falhas=$((falhas + 1))
    fi
done

echo
echo "concluído em $((SECONDS - inicio))s — $((n - falhas))/$total indexados, $falhas falhas"
echo "grafo global: $(graphify global path 2>/dev/null || echo "$BASE/global-graph.json")"
exit $((falhas > 0))
