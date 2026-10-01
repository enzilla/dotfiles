# Preferências pessoais

Estas regras são só minhas, não são política do time. Não as proponha para o repositório central nem as cite em PRs como convenção da Numih.

## Verificar antes de afirmar
- Antes de concluir algo sobre o código, rode `git fetch` e compare com `origin/main` ou com a tag implantada. O checkout local pode estar desatualizado.
- Não diga que uma versão está ou não está implantada sem consultar o ambiente (infra-tf ou Cloud Run).
- Antes de cortar uma release, rode `gh release list` e confirme que não existe versão mais nova.
- Antes de abrir PR no infra, procure com `gh pr list` um PR aberto para o mesmo ambiente e reutilize-o.
- Em infra-tf, confirme qual branch corresponde a qual ambiente antes de editar.
- Build Go falhando: teste também com `GOWORK=off`, porque o go.work pode apontar para clones antigos. Só chame de "pré-existente" depois disso.
- Ao consultar o Tasy, diga explicitamente se foi no DBTESTE ou no DBPROD.
- Regras TISS/ANS: pesquise a documentação oficial em vez de responder de memória.

## Forma de trabalhar
- Bug de produção: apresente a causa raiz com evidências (log, consulta, trecho com caminho e commit) antes de escrever a correção.
- Mudança em vários repositórios ou com subagentes: mostre o desenho em até 10 linhas (contrato, papel de cada repo, comportamento final) e espere minha aprovação. Depois disso, execute sem novas perguntas.
- Prefira comportamento fixo a prop/flag opcional, e contrato neutro a acoplamento com fornecedor (ex.: Tasy). Na dúvida, pergunte antes.
- Um PR por repositório por demanda; não espalhe PRs em rascunho.
- Nunca imprima valores de variáveis de ambiente, DSNs ou segredos; mostre só os nomes.
