#!/usr/bin/env bash
# Guardas pessoais (PreToolUse). Exit 2 bloqueia a chamada e devolve o stderr ao Claude.
input=$(cat)
tool=$(jq -r '.tool_name' <<<"$input")

case "$tool" in
  Bash)
    cmd=$(jq -r '.tool_input.command // empty' <<<"$input")
    if grep -Eq 'git[[:space:]]+tag([[:space:]].*)?[[:space:]](-a|--annotate|-m|-s|--sign)([[:space:]]|$)' <<<"$cmd"; then
      echo "Tag anotada bloqueada: ela quebra o workflow de release. Crie a release pelo fluxo oficial (gh release create / workflow)." >&2
      exit 2
    fi
    if grep -Eq 'git[[:space:]]+push([[:space:]].*)?[[:space:]]HEAD([[:space:]:]|$)' <<<"$cmd"; then
      echo "Push por HEAD bloqueado: empurre pelo nome da branch (git push origin <branch>:<branch>)." >&2
      exit 2
    fi
    # Segredos: despejo do ambiente, leitura de .env (exceto .example) e echo de variável sensível.
    segredo=""
    grep -Eq '(^|[;&|[:space:]])(env|printenv|export -p|set)[[:space:]]*($|[;&|])' <<<"$cmd" && segredo="despejo do ambiente"
    grep -Eq '\b(cat|less|more|head|tail|bat|source|\.)[[:space:]][^|;&]*\.env(\.[A-Za-z0-9_-]+)?([[:space:]"'"'"']|$)' <<<"$cmd" \
      && ! grep -Eq '\.env\.(example|sample|template)' <<<"$cmd" && segredo="leitura de .env"
    grep -Eq '(echo|printf|printenv)[^|;&]*\$\{?[A-Z0-9_]*(DSN|KEY|TOKEN|SECRET|PASSWORD|PASSWD|PASS|CREDENTIALS?)\b' <<<"$cmd" && segredo="impressão de variável sensível"
    grep -Eq 'gcloud[[:space:]]+secrets[[:space:]]+versions[[:space:]]+access' <<<"$cmd" && segredo="leitura de segredo do GSM"
    if [ -n "$segredo" ]; then
      echo "Bloqueado ($segredo): não imprima segredos. Mostre só os nomes (ex.: grep -o '^[A-Z_]*=' .env) ou teste a presença com [ -n \"\$VAR\" ]." >&2
      exit 2
    fi
    ;;
  Edit|Write|MultiEdit)
    f=$(jq -r '.tool_input.file_path // empty' <<<"$input")
    if [[ "$f" == */migrations/* ]] && git -C "$(dirname "$f")" ls-files --error-unmatch "$f" >/dev/null 2>&1; then
      echo "Migration versionada não se edita (produção). Crie uma migration nova em vez de alterar $f." >&2
      exit 2
    fi
    ;;
esac
exit 0
