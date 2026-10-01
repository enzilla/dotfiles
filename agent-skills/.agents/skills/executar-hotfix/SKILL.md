---
name: executar-hotfix
description: Fluxo pessoal de hotfix e release de um módulo Numih — da correção mesclada até a release beta, a imagem publicada e o PR de bump no infra-tf-numih (hom e, se pedido, prod). Use quando eu pedir "hotfix", "cortar release", "subir correção para hom/prod", "bump no infra", "release com cherry-pick" ou "promover para produção".
---

# Hotfix e release

Fluxo **pessoal**, não é política do time. Não o cite como convenção da Numih em PRs nem o proponha no repositório `cursor`.

Escopo: da correção já pronta até o deploy. Branch, issue e implementação seguem a regra de branch/PR do núcleo e a skill `resolver-issues-linear-mcp`.

## Fatos que não se presumem

| Fato | Onde confirmar |
|---|---|
| infra `main` = **produção**, infra `hom` = **homologação** | README do `Numih/infra-tf-numih` |
| Versão em execução | `image_version` em `module-{modulo}-{comp}.tf` de `origin/main` (prod) e `origin/hom` (hom) |
| Formato da tag | `{comp}/vX.Y.Z-beta.N` (`comp` = `server`, `client` ou `worker`); prod também roda beta |
| Imagem Docker | gerada pelo evento `release: published` (`build-docker-image-back.yml` / `-front.yml`) |
| Prod automático | `propose-prod-bumps` (quinta, 15:13) propõe bumps só de pacotes com todas as issues em "Homologado" |

## 1. Levantar o estado real (sempre, antes de qualquer decisão)

```bash
R=Numih/{modulo}; C=server   # ou client
git -C ~/dev/infra-tf-numih fetch -q origin
for b in main hom; do echo "$b: $(git -C ~/dev/infra-tf-numih show origin/$b:module-{modulo}-$C.tf | grep -m1 image_version)"; done
git fetch -q --tags origin
git tag -l "$C/v*" --sort=-version:refname | head -3
gh release list -R $R -L 6
```

Se `module-{modulo}-{comp}.tf` não existir, ache o arquivo com `grep -l "{modulo}" module-*.tf`.

Reporte numa tabela: prod, hom, maior tag existente. Nunca use o checkout local sem `fetch`.

## 2. Escolher o caminho

Compare o que a `main` tem além de prod: `git log --oneline {comp}/{versao_prod}..origin/main -- {comp}/`.

- **Normal**: só a correção (ou apenas coisas que podem ir junto) está entre prod e `main`. A release sai da `main`.
- **Emergência**: a `main` traz trabalho não homologado que não pode ir para prod. A release sai da **tag de prod + cherry-pick**.

Se não estiver claro o que pode ir junto, pergunte. Essa decisão é minha.

### Caminho de emergência

```bash
git worktree add ../{modulo}-hotfix {comp}/{versao_prod} -b fix/{descricao}_prod_{num-xx}
cd ../{modulo}-hotfix
git cherry-pick -x <sha_do_merge_na_main>...
git push origin fix/{descricao}_prod_{num-xx}:fix/{descricao}_prod_{num-xx}
```

- Faça cherry-pick só de commits **já mesclados na `main`**. Se a correção não está na `main`, primeiro abra o PR normal (um PR por repositório).
- Valide antes de cortar: server com `GOWORK=off go build ./... && GOWORK=off go test ./...`; client com o build do pacote.
- Esse branch não vira PR: ele só serve de alvo para a tag.

## 3. Cortar a release

Versão = **maior tag existente do componente + 1** (não "prod + 1": hom costuma estar à frente). Nunca reaproveite um número.

Pelo workflow oficial (preferido):

```bash
gh workflow run create-beta-release.yml -R $R -f component=$C -f version=vX.Y.Z-beta.N -f ref=<sha>
gh run list -R $R -w create-beta-release.yml -L 1    # acompanhe até success
gh release view $C/vX.Y.Z-beta.N -R $R
```

Alternativa aceita pelo time: tag **leve** via refspec, `git push origin <sha>:refs/tags/$C/vX.Y.Z-beta.N`. Nunca tag anotada.

Se mudaram server e client, corte uma release por componente.

## 4. Esperar a imagem

```bash
gh run list -R $R -w build-docker-image-back.yml -L 1   # ou build-docker-image-front.yml
```

Só siga com run `success` para a tag criada. Sem a imagem, o bump aponta para algo que não existe.

## 5. Bump no infra (hom)

```bash
gh pr list -R Numih/infra-tf-numih --base hom --state open --json number,title,headRefName,author
```

- Se houver PR meu, aberto, para `hom` e para o mesmo módulo, atualize-o em vez de abrir outro.
- Senão, crie a branch `chore/bump_{modulo}_hom_{num-xx}` a partir de `origin/hom` em worktree própria, troque o `image_version` e abra o PR com base `hom`.
- Título: `chore(hom): {modulo} {comp} vX.Y.Z-beta.N (NUM-xx)`. No corpo use `Refs NUM-xx`, não `Fixes`, porque a issue ainda vai para homologação.
- Se a tag nova contém mudança de `.graphqls`, avise no PR: a promoção de schema no `nm-graphql-registry` é manual.

## 6. Prod (somente se eu pedir)

- **Caminho normal**: não abra PR. Depois que o QA mover as issues para "Homologado", o `propose-prod-bumps` propõe o bump. Se houver urgência, rode-o com `gh workflow run propose-prod-bumps.yml -R Numih/infra-tf-numih`.
- **Caminho de emergência**: abra PR manual com base `main` (`chore/bump_{modulo}_prod_{num-xx}`, título `chore(prod): ...`). A tag fica fora da linhagem da `main`, então o proposer automático vai pular ou pedir "bump manual necessário uma vez" na próxima proposta. Isso é esperado; diga isso no corpo do PR.

## 7. Fechar o laço

Comente na issue do Linear: tag, link da release, link do PR do infra e qual caminho foi usado. Encerre com uma tabela: repositório, tag base, release criada, status da imagem, PR do infra.

## Não fazer

- Release a partir da `main` quando a `main` tem trabalho não homologado (caminho de emergência).
- Tag anotada, push por `HEAD`, reuso de número de versão.
- Novo PR no infra quando já existe um aberto para o mesmo ambiente e módulo.
- Editar migration existente: crie uma nova.
