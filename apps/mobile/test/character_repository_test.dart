import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/core/network/api_client.dart';
import 'package:rick_and_morty_challenge/src/features/characters/data/character_repository.dart';

void main() {
  test(
    'character repository forwards every UI-supported list filter',
    () async {
      final client = _CharacterApiClient();
      final repository = RemoteCharacterRepository(client);

      final page = await repository.getCharacters(
        page: 2,
        name: 'rick',
        status: 'alive',
        species: 'human',
      );

      expect(client.lastPath, '/characters');
      expect(client.lastQuery, {
        'page': '2',
        'name': 'rick',
        'status': 'alive',
        'species': 'human',
      });
      expect(page.characters.single.name, 'Rick Sanchez');
      expect(page.hasNextPage, isTrue);
    },
  );

  test('character repository parses details and location references', () async {
    final client = _CharacterApiClient();
    final details = await RemoteCharacterRepository(
      client,
    ).getCharacterDetails(1);

    expect(client.lastPath, '/characters/1');
    expect(details.origin.id, 1);
    expect(details.location.name, 'Citadel of Ricks');
    expect(details.episodeIds, [1, 2]);
  });
}

class _CharacterApiClient implements ApiClient {
  String? lastPath;
  Map<String, String>? lastQuery;

  @override
  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, String>? query,
  }) async {
    lastPath = path;
    lastQuery = query;
    if (path == '/characters') {
      return {
        'page': 2,
        'totalPages': 3,
        'totalItems': 50,
        'hasNextPage': true,
        'hasPreviousPage': true,
        'characters': [_summaryJson],
      };
    }

    return {
      ..._summaryJson,
      'origin': {'id': 1, 'name': 'Earth (C-137)'},
      'location': {'id': 3, 'name': 'Citadel of Ricks'},
      'episodeIds': [1, 2],
    };
  }
}

const _summaryJson = <String, dynamic>{
  'id': 1,
  'name': 'Rick Sanchez',
  'status': 'Alive',
  'species': 'Human',
  'type': '',
  'gender': 'Male',
  'image': 'https://example.com/rick.png',
  'origin': 'Earth (C-137)',
  'location': 'Citadel of Ricks',
  'episodeCount': 2,
};
