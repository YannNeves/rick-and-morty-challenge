# Rick and Morty Challenge

Monorepo do desafio tecnico com separacao entre backend e cliente Flutter.

- `apps/api`: API Node.js + TypeScript + Express.
- `apps/mobile`: Flutter para Web, iOS e Android, pinado com FVM.

## Diferenciais implementados

- Backend versionado em `/api/v1`.
- Ordenacao dos personagens no backend, por nome como padrao.
- Busca em lote de personagens usando `/character/1,2,3` para evitar N chamadas.
- Timeout, retry simples, cache em memoria e tratamento padronizado de erros.
- Analytics desacoplado no app, enviado para a propria API sem depender de conta externa.
- Dockerfile, Docker Compose, healthcheck e `.env.example`.
- Testes unitarios e de integracao na API, testes de dominio/controller/widget no Flutter.
- CI com testes, imagem Docker e builds Flutter Web, Android e iOS.
- OpenAPI em `docs/openapi.yaml`.

## Como rodar a API

Requer Node.js `24.20.0`.

```bash
npm --prefix apps/api install
npm run dev:api
```

A API sobe em `http://localhost:3000`.

Endpoints principais:

- `GET /health`
- `GET /api/v1/episodes?page=1`
- `GET /api/v1/episodes/28?sortCharactersBy=name&characterOrder=asc`
- `POST /api/v1/analytics/events`

## Como rodar com Docker

```bash
docker compose up --build
```

## Como rodar o Flutter

O SDK Flutter `3.47.2` e gerenciado pelo FVM. O build Android usa JDK 17.

```bash
fvm use
cd apps/mobile
fvm flutter pub get
fvm flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

No Android emulator, o app usa `http://10.0.2.2:3000/api/v1` por padrao.
No iOS simulator e Web, usa `http://localhost:3000/api/v1`.

## Testes

```bash
npm run lint:api
npm run test:api
npm run build:api
npm run mobile:analyze
npm run mobile:test
```

## Fluxo de contribuicao

Branches, commits e pull requests seguem um padrao rastreavel baseado nas issues
e labels do projeto. Consulte o [guia de contribuicao](CONTRIBUTING.md) antes de
iniciar uma tarefa.

Resumo do fluxo:

```text
Issue -> branch -> commits -> pull request -> CI -> develop -> main
```

## Decisao sobre React

A vaga menciona React, mas o desafio pede API e Flutter web/iOS/Android. Mantive React fora da entrega para nao diluir o escopo principal nem criar um segundo frontend com pouca profundidade. A API esta cliente-agnostica e pronta para receber um `apps/web` em React como extensao.

## Referencias

- Rick and Morty API: https://rickandmortyapi.com/documentation
