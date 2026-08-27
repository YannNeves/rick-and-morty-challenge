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
- widget test abrindo um episodio e exibindo personagens.
