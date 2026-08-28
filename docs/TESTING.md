# Estratégia de testes

## API

A API usa `node:test` com TypeScript carregado por `tsx`. Node 24 já oferece
runner e cobertura com thresholds; adicionar Jest aumentaria dependências e
configuração sem ampliar os cenários testados neste projeto.

```bash
npm --prefix apps/api run lint
npm --prefix apps/api run openapi:lint
npm --prefix apps/api run test:coverage
npm --prefix apps/api run build
```

O threshold bloqueia regressões abaixo de 90% em linhas/funções e 80% em branches.
A suíte cobre:

- serviços e regras de ordenação determinística;
- controllers/rotas Express com gateway fake;
- parsing, batch, validações e páginas vazias;
- timeout, falhas de transporte, `429`, `Retry-After` e backoff;
- cache limitado e deduplicação de requisições em andamento;
- fan-out limitado a quatro tarefas concorrentes.

## Flutter

O cliente usa `flutter_test`, repositories fake/stub e widget tests. Nenhum teste
consulta a API pública.

```bash
cd apps/mobile
fvm flutter analyze
fvm flutter test --coverage
fvm dart run tool/check_coverage.dart coverage/lcov.info 65
```

O threshold é 65% sobre o relatório LCOV integral, incluindo os widgets
exclusivos da Web. Além da cobertura automatizada, esses widgets são validados
por análise, build Web release e smoke test manual.

Cenários cobertos:

- parsing de personagens, episódios e localizações;
- queries de paginação, busca, Status, Espécie e ordenação;
- debounce da pesquisa no fluxo de widget;
- descarte de respostas fora de ordem;
- infinite load, fim de paginação, retry e preservação dos itens;
- estados de controller/ViewModel;
- drawer de filtros, temas, navegação e relacionamentos de detalhes;
- origem e localização atual do personagem.

## Builds de aceite

```bash
docker build --file apps/api/Dockerfile --tag rick-and-morty-api:local .
cd apps/mobile
fvm flutter build web --release \
  --dart-define=API_BASE_URL=https://api.example.invalid/api/v1
fvm flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.example.invalid/api/v1
fvm flutter build ios --simulator --no-codesign \
  --dart-define=API_BASE_URL=https://api.example.invalid/api/v1
```

O domínio `.invalid` é usado apenas em verificação de compilação. Um artefato
distribuível deve receber a URL real da API própria.

## CI

A CI executa lint, OpenAPI, cobertura, builds da API, Docker, Web, APK release e
iOS Simulator. Runs antigos do mesmo branch são cancelados e Web/APK são
publicados como artefatos. Não existe etapa de deploy.

Os números e percentuais da execução final são registrados no resumo da entrega;
não devem ser atualizados neste documento sem rodar novamente as suítes.
