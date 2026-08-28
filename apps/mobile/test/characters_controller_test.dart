import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/features/characters/data/character_repository.dart';
import 'package:rick_and_morty_challenge/src/features/characters/domain/character_models.dart';
import 'package:rick_and_morty_challenge/src/features/characters/presentation/characters_controller.dart';

void main() {
  test('forwards status and species and sorts the loaded characters', () async {
    final repository = _RecordingCharacterRepository();
    final controller = CharactersController(characterRepository: repository);

    await controller.load(
      name: 'rick',
      filters: const {'status': 'alive', 'species': 'human', 'sortBy': 'name'},
    );

    expect(repository.lastName, 'rick');
    expect(repository.lastStatus, 'alive');
    expect(repository.lastSpecies, 'human');
    expect(controller.characters.map((item) => item.name), ['Amy', 'Zeta']);
  });

  test('ignores a stale response after a newer search starts', () async {
    final repository = _DeferredCharacterRepository();
    final controller = CharactersController(characterRepository: repository);

    final oldLoad = controller.load(name: 'old');
    final newLoad = controller.load(name: 'new');
    repository.complete('new', _page([_character(2, 'New result')]));
    await newLoad;
    repository.complete('old', _page([_character(1, 'Old result')]));
    await oldLoad;

    expect(controller.characters.single.name, 'New result');
    expect(controller.status, CharactersLoadStatus.success);
  });

  test('preserves loaded characters when the next page fails', () async {
    final repository = _FailingNextPageRepository();
    final controller = CharactersController(characterRepository: repository);

    await controller.load();
    await controller.loadMore();

    expect(controller.characters.single.name, 'Rick Sanchez');
    expect(controller.status, CharactersLoadStatus.success);
    expect(controller.loadMoreErrorMessage, isNotNull);

    await controller.retryLoadMore();
    expect(repository.calls, 3);
  });
}

CharacterSummary _character(int id, String name) => CharacterSummary(
  id: id,
  name: name,
  status: 'Alive',
  species: 'Human',
  type: '',
  gender: 'Unknown',
  image: '',
  origin: 'Earth',
  location: 'Earth',
  episodeCount: 1,
);

CharacterListPage _page(
  List<CharacterSummary> characters, {
  int page = 1,
  bool hasNextPage = false,
}) => CharacterListPage(
  page: page,
  totalPages: hasNextPage ? page + 1 : page,
  totalItems: characters.length,
  hasNextPage: hasNextPage,
  hasPreviousPage: page > 1,
  characters: characters,
);

class _RecordingCharacterRepository implements CharacterRepository {
  String? lastName;
  String? lastStatus;
  String? lastSpecies;

  @override
  Future<CharacterListPage> getCharacters({
    int page = 1,
    String? name,
    String? status,
    String? species,
  }) async {
    lastName = name;
    lastStatus = status;
    lastSpecies = species;
    return _page([_character(2, 'Zeta'), _character(1, 'Amy')]);
  }

  @override
  Future<CharacterDetails> getCharacterDetails(int id) =>
      throw UnimplementedError();
}

class _DeferredCharacterRepository implements CharacterRepository {
  final Map<String, Completer<CharacterListPage>> _requests = {};

  void complete(String name, CharacterListPage page) {
    _requests[name]!.complete(page);
  }

  @override
  Future<CharacterListPage> getCharacters({
    int page = 1,
    String? name,
    String? status,
    String? species,
  }) {
    final completer = Completer<CharacterListPage>();
    _requests[name ?? ''] = completer;
    return completer.future;
  }

  @override
  Future<CharacterDetails> getCharacterDetails(int id) =>
      throw UnimplementedError();
}

class _FailingNextPageRepository implements CharacterRepository {
  int calls = 0;

  @override
  Future<CharacterListPage> getCharacters({
    int page = 1,
    String? name,
    String? status,
    String? species,
  }) async {
    calls += 1;
    if (page > 1) throw Exception('rate limited');
    return _page([_character(1, 'Rick Sanchez')], hasNextPage: true);
  }

  @override
  Future<CharacterDetails> getCharacterDetails(int id) =>
      throw UnimplementedError();
}
