# Preferências pessoais


## Verificar antes de afirmar
- Antes de concluir algo sobre o código, rode `git fetch` e compare com `origin/main` ou com a tag implantada. O checkout local pode estar desatualizado.
- Antes de cortar uma release, rode `gh release list` e confirme que não existe versão mais nova.
- Antes de abrir PR no infra, procure com `gh pr list` um PR aberto para o mesmo ambiente e reutilize-o.
- Build Go falhando: teste também com `GOWORK=off`, porque o go.work pode apontar para clones antigos. Só chame de "pré-existente" depois disso.
- Regras TISS/ANS: pesquise a documentação oficial em vez de responder de memória.

## Forma de trabalhar
- Bug de produção: apresente a causa raiz com evidências (log, consulta, trecho com caminho e commit) antes de escrever a correção.
- Mudança em vários repositórios ou com subagentes: mostre o desenho em até 10 linhas (contrato, papel de cada repo, comportamento final) e espere minha aprovação. Depois disso, execute sem novas perguntas.
- Um PR por repositório por demanda; não espalhe PRs em rascunho.
- Nunca imprima valores de variáveis de ambiente, DSNs ou segredos; mostre só os nomes.

## Ferramentas pessoais
- Bug de produção ou homologação: delegue primeiro ao agente `investigar-producao` e só implemente depois do diagnóstico.
- Antes de abrir PR: rode o agente `revisar-criterios-aceite` com a branch e a issue.
- Hotfix e release: skill `executar-hotfix`.
- Credenciais: use as ações do `secret-broker` (`secret-broker list` / `run`), que injetam o segredo só no processo filho. Nunca rode `bw get` nem leia o `token` do broker.

## Navegação no browser
- Use o `agent-browser` (CLI) em vez da extensão do Chrome. A config em `~/.agent-browser/config.json` já aponta para o Brave com um perfil próprio, logado no hom. Use a extensão só se eu pedir.
- O padrão é headless, por desempenho. Use `--headed` (com `WAYLAND_DISPLAY=wayland-1`) só se eu pedir para acompanhar.
- Leia a página com `snapshot -i -c` e aja pelas refs (`@eN`), não por coordenada. Agrupe os passos previsíveis em `agent-browser batch --bail`.
- Tire `screenshot` com caminho absoluto no scratchpad (caminho relativo grava no repositório) a cada tela relevante: estado inicial, cada ação significativa, erro e resultado final.
- Ao final, entregue um relatório completo da navegação: um arquivo HTML local no scratchpad, com os prints embutidos, sem publicar como Artifact. Me passe o caminho do arquivo. Ele traz o objetivo, cada passo (o que fiz, o que a tela mostrou e o print) e o que deu errado. Quando for homologação de issue, traz também a conclusão por critério de aceite (aprovado ou reprovado, com a evidência).

## Repositório rpa
- Mudança em runner ou fluxo de portal: antes de abrir PR, execute o fluxo em dry-run contra o portal real e relate as telas e as respostas do portal. Só abra PR e corte release se o dry-run passar.
