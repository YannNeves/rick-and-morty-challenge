# Rick and Morty Flutter App

Cliente Flutter do desafio.

SDK fixado pelo FVM: Flutter `3.47.2`.
O build Android requer JDK 17.

Suporta:

- Web;
- Android;
- iOS.

## Rodar

Na raiz do monorepo, com o simulador ou dispositivo desejado conectado:

```bash
npm run mobile:run:ios
npm run mobile:run:android
npm run mobile:run:web
```

Diretamente neste diretório:

```bash
fvm flutter pub get
fvm flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

## Validar

```bash
fvm flutter analyze
fvm flutter test --coverage
fvm dart run tool/check_coverage.dart coverage/lcov.info 65
fvm flutter build web --release --dart-define=API_BASE_URL=https://api.example.invalid/api/v1
fvm flutter build apk --release --dart-define=API_BASE_URL=https://api.example.invalid/api/v1
fvm flutter build ios --simulator --no-codesign --dart-define=API_BASE_URL=https://api.example.invalid/api/v1
```

## Configurações

- `API_BASE_URL`: base da API Node. Padrão Web/iOS em desenvolvimento:
  `http://localhost:3000/api/v1`; Android Emulator: `http://10.0.2.2:3000/api/v1`.
- release exige uma URL HTTP(S) explícita e não local. O domínio `.invalid` acima
  valida somente a compilação e deve ser substituído antes da distribuição.

## Arquitetura

O aplicativo adota MVVM orientado por feature, com View/ViewModel na camada de UI,
Repository/Service na camada de dados e use cases apenas quando a complexidade
justificar. Consulte a
[arquitetura e as decisões técnicas](../../docs/ARCHITECTURE.md) antes de criar ou
reorganizar uma feature.
