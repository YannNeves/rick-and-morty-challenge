# Testes

## API

```bash
npm --prefix apps/api run lint
npm --prefix apps/api test
npm --prefix apps/api run build
```

Cobertura principal:

- extracao de ids das URLs de personagens;
- ordenacao de personagens;
- caso de uso de detalhes do episodio com busca em lote;
- retry, timeout, cache e respostas do cliente HTTP externo;
- rotas HTTP principais com gateway fake.

## Flutter

```bash
cd apps/mobile
fvm flutter analyze
fvm flutter test
```

Cobertura principal:

- parsing dos DTOs da API;
- repository enviando query de paginacao e ordenacao;
- controller carregando dados e disparando analytics;
- analytics sem bloquear a atualizacao da interface;
- widget test abrindo um episodio e exibindo personagens.

## Builds de entrega

```bash
docker build --file apps/api/Dockerfile --tag rick-and-morty-api:local .
cd apps/mobile
fvm flutter build web
fvm flutter build apk --debug
fvm flutter build ios --simulator --no-codesign
```

O build Android usa JDK 17. O build iOS requer macOS com Xcode. A CI executa os
tres targets Flutter e a construcao da imagem da API.
