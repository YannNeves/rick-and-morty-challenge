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

Diretamente neste diretorio:

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

## Arquitetura

O aplicativo adota MVVM orientado por feature, com View/ViewModel na camada de UI,
Repository/Service na camada de dados e use cases apenas quando a complexidade
justificar. Consulte a
[especificacao de arquitetura](../../docs/FLUTTER_ARCHITECTURE.md) antes de criar
ou reorganizar uma feature.
