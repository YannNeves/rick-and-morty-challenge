# Rick and Morty Flutter App

Cliente Flutter do desafio.

SDK fixado pelo FVM: Flutter `3.47.2`.
O build Android requer JDK 17.

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
fvm flutter build web
fvm flutter build apk --debug
fvm flutter build ios --simulator --no-codesign
```

## Configuracoes

- `API_BASE_URL`: base da API Node. Padrao Web/iOS: `http://localhost:3000/api/v1`; Android emulator: `http://10.0.2.2:3000/api/v1`.
- `ANALYTICS_ENABLED`: `true` por padrao. Use `false` para desabilitar envio de eventos.
