# Guia de contribuicao

Este projeto usa GitHub Issues, GitHub Projects e Conventional Commits para
manter rastreabilidade entre tarefa, implementacao, revisao e entrega.

## Fluxo de trabalho

O fluxo padrao e:

```text
Issue -> branch -> commits -> pull request -> CI -> develop -> main
```

- `main` representa a versao estavel.
- `develop` concentra as alteracoes aprovadas para a proxima entrega.
- Branches de trabalho devem nascer de `develop`.
- Nao devem ser feitos commits diretamente em `main` ou `develop`.
- Cada branch deve estar vinculada a uma issue principal.

## Labels das issues

Cada issue deve receber:

- exatamente uma label `type:*`;
- uma ou mais labels `area:*`;
- exatamente uma label `priority:*`;
- a milestone correspondente a entrega.

Tipos suportados:

| Label | Uso | Prefixo da branch | Tipo do commit |
| --- | --- | --- | --- |
| `type: feature` | Nova funcionalidade | `feat/` | `feat` |
| `type: bug` | Correcao de comportamento | `fix/` | `fix` |
| `type: test` | Testes automatizados ou manuais | `test/` | `test` |
| `type: docs` | Documentacao | `docs/` | `docs` |
| `type: chore` | Ferramentas e manutencao | `chore/` | `chore` |

Areas suportadas:

| Label | Scope do commit |
| --- | --- |
| `area: backend` | `backend` |
| `area: flutter` | `flutter` |
| `area: devops` | `devops` |
| `area: architecture` | `architecture` |

## Nomenclatura de branches

Use o formato:

```text
<tipo>/<issue>-<descricao-curta>
```

Regras:

- usar letras minusculas;
- usar hifens como separadores;
- nao usar acentos, espacos ou caracteres especiais;
- manter a descricao curta e orientada ao resultado.

Exemplos:

```text
feat/2-episode-integration
feat/3-character-sorting
test/5-api-tests
chore/7-docker-ci
docs/8-architecture-documentation
test/10-manual-tests
```

Para iniciar uma tarefa:

```bash
git switch develop
git pull --ff-only
git switch -c feat/2-episode-integration
```

## Nomenclatura de commits

Use Conventional Commits com o numero da issue:

```text
<tipo>(<area>): <descricao> (#<issue>)
```

Exemplos:

```text
feat(backend): implementa listagem paginada de episodios (#2)
feat(backend): ordena personagens por nome e id (#3)
feat(flutter): adiciona tela de detalhes do episodio (#4)
test(backend): cobre parametros invalidos de ordenacao (#5)
chore(devops): adiciona pipeline de integracao continua (#7)
docs(architecture): documenta fluxo entre API e cliente (#8)
fix(backend): preserva o path base da API externa (#2)
```

Regras para a descricao:

- usar verbo no presente, como `adiciona`, `implementa`, `corrige` ou `documenta`;
- iniciar com letra minuscula;
- nao terminar com ponto;
- manter a primeira linha com aproximadamente 72 caracteres;
- representar uma alteracao coerente por commit;
- adicionar `(#N)` para vincular o commit a issue no GitHub.

Nao use `Closes #N` em commits intermediarios. A issue deve ser fechada apenas
quando o pull request for integrado.

## Pull requests

O titulo do pull request deve seguir o mesmo padrao do commit, sem o numero da
issue quando ela ja estiver declarada no corpo:

```text
feat(backend): implementa integracao de episodios
```

O pull request deve:

- ter `develop` como destino para mudancas de implementacao;
- explicar contexto e alteracoes realizadas;
- informar como a mudanca foi validada;
- passar pelos checks de CI;
- usar `Closes #N` no corpo para fechar a issue no merge.

Exemplo:

```markdown
## Contexto

Implementa a consulta e transformacao dos episodios da Rick and Morty API.

## Alteracoes

- Listagem paginada
- Filtros por nome e codigo
- Consulta por ID
- Tratamento de erros externos

## Validacao

- [x] Testes automatizados
- [x] Typecheck
- [x] Build
- [x] Teste manual

Closes #2
```

## Status no quadro

As tarefas devem percorrer o fluxo:

```text
Backlog -> Ready -> In progress -> In review -> Done
```

Use `Blocked` quando existir um impedimento concreto. Uma tarefa somente deve ir
para `Done` depois do merge e da validacao dos criterios de aceite.

