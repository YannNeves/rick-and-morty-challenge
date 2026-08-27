# Rick and Morty Flutter App

Cliente Flutter do desafio.

Suporta:

- Web;
- Android;
- iOS.

## Rodar

```bash
fvm flutter pub get
fvm flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

## Validar

```bash
fvm flutter analyze
fvm flutter test
```

## Configuracoes

- `API_BASE_URL`: base da API Node. Padrao Web/iOS: `http://localhost:3000/api/v1`; Android emulator: `http://10.0.2.2:3000/api/v1`.
- `ANALYTICS_ENABLED`: `true` por padrao. Use `false` para desabilitar envio de eventos.
