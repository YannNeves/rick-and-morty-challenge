# API

Base local: `http://localhost:3000/api/v1`

Este é o guia humano do contrato. A especificação formal, incluindo schemas e
respostas de erro, está em [`openapi.yaml`](openapi.yaml).

## `GET /characters`

Lista personagens paginados. A API externa retorna até 20 itens por página.
Filtros sem correspondência retornam `200` com `characters: []` e totais zerados.

Query params:

- `page`: número positivo, padrão `1`.
- `name`: nome parcial.
- `status`: `alive`, `dead` ou `unknown`.
- `species`: espécie.
- `type`: tipo ou subespécie.
- `gender`: `female`, `male`, `genderless` ou `unknown`.

Exemplo:

```bash
curl "http://localhost:3000/api/v1/characters?page=1&name=rick&status=alive"
```

## `GET /characters/:id`

Retorna os detalhes de um personagem. Origem e localização incluem os IDs
extraídos dos relacionamentos externos; `episodeIds` permite navegar para os
episódios sem expor URLs da API upstream.

```bash
curl "http://localhost:3000/api/v1/characters/2"
```

## `GET /characters/batch`

Retorna até 100 personagens por chamada. `ids` é obrigatório, aceita somente
inteiros positivos e remove duplicidades preservando a ordem solicitada.

```bash
curl "http://localhost:3000/api/v1/characters/batch?ids=1,183"
```

## `GET /locations`

Lista localizações paginadas com contrato próprio e contagem de residentes.

Query params:

- `page`: número positivo, padrão `1`.
- `name`: nome parcial.
- `type`: tipo da localização.
- `dimension`: dimensão da localização.

```bash
curl "http://localhost:3000/api/v1/locations?page=1&name=citadel"
```

## `GET /locations/:id`

Retorna a localização e seus residentes mapeados, ordenados por nome e ID.

```bash
curl "http://localhost:3000/api/v1/locations/3"
```

## Coleções completas

O backend consulta a primeira página, agrega as demais com até quatro chamadas
simultâneas e devolve a coleção globalmente ordenada.

- `GET /characters/all`
- `GET /episodes/all`
- `GET /locations/all`

O Flutter usa páginas na Home e no infinite load de personagens. As telas gerais
de episódios e localizações usam `/all` para filtrar e ordenar a coleção completa.
Em `/characters/all`, a ordem é nome com desempate por ID; na lista infinita, a
ordenação abrange somente o conjunto já carregado.

## `GET /locations/batch`

Retorna até 100 localizações, removendo duplicidades e preservando a ordem dos IDs.

```bash
curl "http://localhost:3000/api/v1/locations/batch?ids=3,21"
```

## `GET /episodes`

Lista episódios paginados.

Query params:

- `page`: número positivo, padrão `1`.
- `name`: filtro opcional repassado para a Rick and Morty API.
- `episode`: filtro opcional por código, exemplo `S03E07`.

## `GET /episodes/batch`

Retorna até 100 resumos de episódios, removendo duplicidades e preservando a ordem.

```bash
curl "http://localhost:3000/api/v1/episodes/batch?ids=10,28"
```

## `GET /episodes/:id`

Retorna episódio e personagens participantes.

Query params:

- `sortCharactersBy`: `name`, `id`, `status` ou `species`. Padrão `name`.
- `characterOrder`: `asc` ou `desc`. Padrão `asc`.

Exemplo:

```bash
curl "http://localhost:3000/api/v1/episodes/28?sortCharactersBy=name&characterOrder=asc"
```

O mesmo comparador e desempate por ID são usados nos residentes de uma localização
e na coleção completa de personagens.

## Resiliência upstream

- timeout configurável por requisição;
- até três tentativas para transporte, `429`, `502`, `503` e `504`;
- respeito ao cabeçalho `Retry-After` ou backoff exponencial com jitter;
- deduplicação de chamadas idênticas em andamento;
- cache TTL limitado por `CACHE_MAX_ENTRIES` (500 por padrão);
- detalhes inexistentes permanecem `404`; `404` upstream de uma listagem filtrada
  se torna uma página vazia `200`.

## Erros

Erros seguem o formato:

```json
{
  "error": {
    "code": "BAD_REQUEST",
    "message": "id must be a positive integer",
    "details": {}
  }
}
```

## Postman

Os artefatos abaixo acompanham o contrato e podem ser importados diretamente:

- [`rick-and-morty-api.postman_collection.json`](postman/rick-and-morty-api.postman_collection.json)
- [`rick-and-morty-api.postman_environment.json`](postman/rick-and-morty-api.postman_environment.json)

### Importar e executar

1. Abra o Postman e selecione **Import**.
2. Importe a collection e o environment acima.
3. Selecione **Rick and Morty API - Local**.
4. Inicie a API com `npm run dev:api`.
5. Execute primeiro **Health check** e depois as pastas Characters, Locations e
   Episodes, ou use **Run collection**.

O environment usa `http://localhost:3000` e permite alterar `characterId`,
`episodeId` e `locationId` sem editar as requisições. A variável
`missingCharacterName` deve continuar com um valor inexistente para validar o
retorno vazio `200`.

A collection possui verificações para paginação, filtros, `/all`, `/batch`,
detalhes, relacionamentos, ordenação determinística e erros normalizados. Chamadas
`/all` podem demorar mais na primeira execução; as seguintes podem usar o cache.
