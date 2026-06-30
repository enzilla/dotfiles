---
name: speckit-init
description: Inicializa o motor do GitHub Spec Kit (specify) em um repositório, sem duplicar os comandos (que são globais em ~/.claude/commands) e já deixando o motor .specify/ no .gitignore. Use quando o usuário pedir para "inicializar o specify", "iniciar o spec kit neste repo", "bootstrap do specify", "habilitar speckit aqui", ou ao precisar rodar /speckit.* num repo que ainda não tem .specify/.
---

# Inicializar Spec Kit (specify) em um repositório

## Contexto desta máquina

Os comandos `/speckit.*` são **globais** — vivem em `~/.claude/commands/speckit.*.md`
e aparecem em **todo** repositório. NÃO reinstale comandos por repo.

O que é **por-repo** é o motor `.specify/` (scripts em `.specify/scripts/bash/*.sh`,
templates, `memory/constitution.md`, e os `specs/` gerados). Os comandos executam
`.specify/scripts/bash/*.sh` a partir da raiz do projeto, então cada repo onde você
for rodar o fluxo precisa do seu próprio `.specify/`.

Por que não dá pra globalizar o motor: os comandos referenciam `.specify/` por
caminho relativo à raiz do repo e os scripts gravam `specs/` e `.specify/feature.json`
dentro do projeto. Tentar usar `--integration claude` falha em repos cujo
`.claude/skills` é symlink pra fora do repo (layout Numih/cursor) — por isso usamos
o integration `generic`, que escreve numa pasta dentro do repo e não toca o symlink.

## Pré-requisitos

- `specify` instalado (`specify --version`). Se faltar: `uv tool install specify-cli` (ou conforme o setup da máquina).
- Estar na raiz do repositório alvo (que deve ser um repo git).

## Passos

Rode na raiz do repositório alvo. É idempotente e não toca `~/.claude` nem os
symlinks `.claude/rules` / `.claude/skills`.

```bash
set -e

# 1. Cria SÓ o motor .specify/. O integration generic exige --commands-dir DENTRO
#    do repo (ele valida containment; caminho fora da raiz é rejeitado), então
#    mandamos os comandos pra uma pasta temporária e apagamos depois — os comandos
#    reais já são globais em ~/.claude/commands.
TMP=.speckit-bootstrap-tmp
specify init . --force --ignore-agent-tools \
  --integration generic --integration-options="--commands-dir $TMP"

# 2. Remove o que não queremos versionar/poluir: comandos duplicados e o AGENTS.md
#    (o specify gera AGENTS.md como context file do generic; aqui usamos CLAUDE.md).
rm -rf "$TMP" AGENTS.md

# 3. Gitignora o motor por-repo.
if ! grep -qxF '.specify/' .gitignore 2>/dev/null; then
  printf '\n# Spec Kit: motor por-repo (os comandos /speckit.* sao globais em ~/.claude/commands)\n.specify/\n' >> .gitignore
fi

echo "Spec Kit pronto neste repo. Rode /speckit.constitution ou /speckit.specify."
```

## Verificação

- `.specify/scripts/bash/` deve existir (ex.: `setup-plan.sh`, `create-new-feature.sh`).
- `.specify/` deve estar listado no `.gitignore` (e portanto não aparecer em `git status`).
- `.speckit-bootstrap-tmp/` e `AGENTS.md` NÃO devem ter sobrado.
- Os symlinks `.claude/rules` / `.claude/skills` continuam intactos.

## Observações

- Se o usuário quiser **versionar** a constituição/specs em vez de ignorar, não
  adicione `.specify/` ao `.gitignore` (ou ignore só `.specify/feature.json` e
  `.specify/extensions/`); confirme a preferência antes.
- Para atualizar o Spec Kit no futuro, rode os passos de novo: `--force` faz o
  merge dos templates/scripts sobre os existentes.
