# Analytics

O app tem um `AnalyticsTracker` desacoplado:

- `ApiAnalyticsTracker`: envia eventos para `POST /api/v1/analytics/events`.
- `NoopAnalyticsTracker`: desliga analytics via `--dart-define=ANALYTICS_ENABLED=false`.

Isso permite demonstrar o fluxo sem depender de credenciais no desafio.

Para uma entrega produtiva, a mesma interface pode receber uma implementacao gratuita como:

- PostHog Cloud Free;
- Firebase Analytics;
- Plausible self-hosted.

Como o contrato ja esta isolado, trocar a implementacao nao muda telas, controllers ou repositories.
