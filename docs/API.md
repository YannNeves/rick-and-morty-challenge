# API

Base local: `http://localhost:3000/api/v1`

## `GET /characters`

Lista personagens paginados. A API externa retorna até 20 itens por página.

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

## `GET /episodes`

Lista episodios paginados.

Query params:

- `page`: numero positivo, padrao `1`.
- `name`: filtro opcional repassado para a Rick and Morty API.
- `episode`: filtro opcional por codigo, exemplo `S03E07`.

## `GET /episodes/:id`

Retorna episodio e personagens participantes.

Query params:

- `sortCharactersBy`: `name`, `id`, `status` ou `species`. Padrao `name`.
- `characterOrder`: `asc` ou `desc`. Padrao `asc`.

Exemplo:

```bash
curl "http://localhost:3000/api/v1/episodes/28?sortCharactersBy=name&characterOrder=asc"
```

## `POST /analytics/events`

Recebe eventos do app.

Eventos aceitos:

- `app_opened`
- `episode_list_viewed`
- `episode_details_viewed`
- `character_sort_changed`

```json
{
  "name": "episode_details_viewed",
  "properties": {
    "episodeId": 28,
    "sortBy": "name"
  }
}
```

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
