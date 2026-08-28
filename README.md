# Rick and Morty Challenge

Monorepo de uma aplicação responsiva para explorar personagens, localizações e
episódios de Rick and Morty. O cliente Flutter (Web, Android e iOS) consome
exclusivamente uma API intermediária Node.js, responsável por normalizar o
contrato público, ordenar dados e proteger os clientes das particularidades da
API externa.

## Considerações

- O projeto é um monorepo com separação explícita entre a API Node.js e o cliente
  Flutter. Web, Android e iOS consomem exclusivamente o contrato próprio em
  `/api/v1`.
- A ordenação de personagens foi tratada como regra de domínio no backend. O
  mesmo comparador determinístico, com desempate por ID, é usado em episódios,
  residentes e `/characters/all`.
- Web e mobile compartilham regras e dados, mas possuem composições responsivas
  intencionalmente diferentes, seguindo o
  [Figma do projeto](https://www.figma.com/design/dG1onUjhPp9TQW4DMBCTYm/Rick-and-Morty?node-id=0-1&p=f&t=y6kW51dQXKj2nFGZ-0).
- Favoritos, autenticação e um cliente React separado ficaram fora do escopo. O
  tempo foi priorizado em arquitetura, resiliência, testes e experiência nos três
  targets Flutter.
- O pipeline implementa CI, cobertura, Docker e gera artefatos release. Não há
  CD porque nenhum ambiente ou credencial de publicação foi fornecido.
- O arquivo `apps/api/.env.example` já está preenchido com valores locais seguros,
  sem secrets, para facilitar a configuração por quem for executar e avaliar o
  projeto.
- Para uma revisão objetiva, a ordem sugerida é: este README,
  [arquitetura](docs/ARCHITECTURE.md), [testes](docs/TESTING.md) e
  [contrato da API](docs/API.md).

## Histórico de live coding

O arquivo [`archive/js-challenge/teste.js`](archive/js-challenge/teste.js) foi
mantido deliberadamente como registro de um live coding anterior. Durante a
entrevista original, não consegui concluir todos os requisitos dentro do tempo;
finalizei o exercício posteriormente, sem uso de IA, e o deixo disponível para
reavaliação, caso seja pertinente.

Esse arquivo está isolado em `archive`, não integra a aplicação Rick and Morty,
seus builds, cobertura ou decisões arquiteturais.

## Stack e estrutura

- `apps/api`: Node.js 24, TypeScript, Express, `node:test` e Docker.
- `apps/mobile`: Flutter 3.47.2, Dart, Material e FVM para Web/iOS/Android.
- `docs`: contrato da API, arquitetura e estratégia de testes.
- `.github/workflows/ci.yml`: integração contínua; não há deploy sem um ambiente
  de destino definido.

## Destaques

- arquitetura modular no backend e MVVM orientado por feature no Flutter;
- temas claro e escuro e layouts específicos para Web e mobile;
- Home e listagem de personagens com paginação infinita;
- pesquisa com debounce, filtros, ordenação e proteção contra respostas antigas;
- detalhes e navegação cruzada entre personagens, episódios e localizações;
- personagens de episódios e residentes ordenados de forma determinística;
- retry de `429/502/503/504`, `Retry-After`, backoff, cache limitado e deduplicação
  de requisições em andamento;
- Docker multi-stage, processo non-root, healthcheck, CI e artefatos release;
- testes automatizados e contrato OpenAPI validado.

Favoritos e React foram removidos do escopo para concentrar a entrega no cliente
Flutter solicitado e na confiabilidade da API.

## Design

As interfaces Web e mobile foram implementadas a partir do
[Figma Rick and Morty](https://www.figma.com/design/dG1onUjhPp9TQW4DMBCTYm/Rick-and-Morty?node-id=0-1&p=f&t=y6kW51dQXKj2nFGZ-0),
com adaptações responsivas e componentes compartilhados no Flutter.

## Funcionalidades

- Home responsiva na ordem Localizações, Episódios e Personagens;
- temas claro e escuro;
- paginação independente nas seções da Home;
- infinite load vertical na listagem geral de personagens;
- pesquisa textual, filtros e ordenação;
- debounce de 350 ms e proteção contra respostas antigas;
- detalhes de personagens, episódios e localizações;
- navegação entre entidades relacionadas;
- origem e localização atual do personagem;
- tradução de valores desconhecidos;
- estados de carregamento, vazio, falha e nova tentativa;
- preservação dos itens quando somente a próxima página falha.

O botão “Ver todos” leva à experiência dedicada, que oferece busca,
ordenação e maior densidade de conteúdo. Favoritos, autenticação, deep links,
cliente React e publicação automática ficaram fora do escopo.

## Requisitos

- Node.js `24.20.0` (consulte `.nvmrc`);
- Flutter `3.47.2` por FVM;
- JDK 17 para Android;
- Xcode atual para iOS;
- Docker, opcional para executar a API em contêiner.

## Instalação

```bash
npm ci --prefix apps/api
fvm use
cd apps/mobile
fvm flutter pub get
cd ../..
```

## Execução

API local:

```bash
cp apps/api/.env.example apps/api/.env
npm run dev:api
```

Cliente, em terminais separados quando necessário:

```bash
npm run mobile:run:web
npm run mobile:run:ios
npm run mobile:run:android
```

Web e iOS Simulator usam `localhost`; o Android Emulator usa `10.0.2.2` para
alcançar a API no host. As configurações do VS Code usam aliases portáveis de
dispositivo (`ios`, `android` e `chrome`).

Com Docker:

```bash
npm run docker:up
```

## Configuração de release

Builds release exigem uma URL HTTP(S) explícita e rejeitam localhost em runtime:

```bash
cd apps/mobile
fvm flutter build web --release \
  --dart-define=API_BASE_URL=https://api.exemplo.com/api/v1
fvm flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.exemplo.com/api/v1
```

Defina a variável de repositório `API_BASE_URL` no GitHub antes de distribuir os
artefatos da CI. O fallback `.invalid` do pipeline serve somente para verificar a
compilação quando ainda não existe infraestrutura publicada.

## Problemas comuns

### API ou porta indisponível

Confirme `npm run dev:api` e `GET http://localhost:3000/health`. Se alterar
`PORT` em `apps/api/.env`, ajuste também a `API_BASE_URL` do cliente.

### Android não alcança localhost

O Android Emulator usa `10.0.2.2` para acessar o host. Em um dispositivo físico,
use o IP da máquina na rede e permita essa origem na API.

### `Device not found`

Execute `fvm flutter devices` e inicie o Simulator ou Emulator antes do comando.
As configurações do VS Code usam os aliases `ios` e `android`; quando houver
ambiguidade, execute `fvm flutter run -d <id>`.

Para Android e iOS simultâneos, use um terminal por processo `flutter run`.
Avalie desempenho Android com `--profile`, pois o modo debug inclui JIT, asserts
e observabilidade.

### CocoaPods

Depois de alterar plugins nativos, execute `pod install` em `apps/mobile/ios`,
seguido de `fvm flutter clean` e `fvm flutter pub get`.

### Rate limit `429`

A API respeita `Retry-After`, repete falhas temporárias e preserva itens já
carregados. Se o upstream continuar limitando, aguarde e use “Tentar novamente”.

## Qualidade

```bash
npm run lint:api
npm --prefix apps/api run openapi:lint
npm --prefix apps/api run test:coverage
npm run build:api
npm run mobile:analyze
npm run mobile:test:coverage
```

A CI também gera a imagem Docker, Web release, APK release e iOS Simulator sem
assinatura. Ela é corretamente apresentada como **CI**, não CI/CD, pois não há
destino de deploy configurado.

## Documentação

- [API e exemplos](docs/API.md)
- [Contrato OpenAPI](docs/openapi.yaml)
- [Arquitetura e decisões técnicas](docs/ARCHITECTURE.md)
- [Estratégia de testes](docs/TESTING.md)
- [Postman](docs/API.md#postman)

## Contribuição

O fluxo recomendado é
`issue -> branch -> commits -> pull request -> CI -> develop -> main`.
O planejamento e o acompanhamento das tarefas estão no
[GitHub Project do desafio](https://github.com/users/YannNeves/projects/1).
Consulte também [CONTRIBUTING.md](CONTRIBUTING.md).

Referência externa: [Rick and Morty API](https://rickandmortyapi.com/documentation).
