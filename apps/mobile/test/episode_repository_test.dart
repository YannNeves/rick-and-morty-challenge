import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/core/network/api_client.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/data/episode_repository.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/character_sort.dart';

void main() {
  test('RemoteEpisodeRepository sends pagination query', () async {
    final client = FakeApiClient();
    final repository = RemoteEpisodeRepository(client);

    await repository.getEpisodes(page: 2);

    expect(client.lastPath, '/episodes');
    expect(client.lastQuery, {'page': '2'});
  });

  test('RemoteEpisodeRepository requests backend character sorting', () async {
    final client = FakeApiClient();
    final repository = RemoteEpisodeRepository(client);

    await repository.getEpisodeDetails(28, sortBy: CharacterSortBy.species);

    expect(client.lastPath, '/episodes/28');
    expect(client.lastQuery, {
      'sortCharactersBy': 'species',
      'characterOrder': 'asc',
    });
  });

  test('RemoteEpisodeRepository requests all episodes once', () async {
    final client = FakeApiClient();
    final repository = RemoteEpisodeRepository(client);

    await repository.getAllEpisodes();

    expect(client.lastPath, '/episodes/all');
    expect(client.lastQuery, isNull);
  });
}

class FakeApiClient implements ApiClient {
  String? lastPath;
  Map<String, String>? lastQuery;

  @override
  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, String>? query,
  }) async {
    lastPath = path;
    lastQuery = query;

    if (path == '/episodes') {
      return {
        'page': 2,
        'totalPages': 3,
        'totalItems': 51,
        'hasNextPage': true,
        'hasPreviousPage': true,
        'episodes': <Map<String, dynamic>>[],
      };
    }

    return {
      'id': 28,
      'name': 'The Ricklantis Mixup',
      'airDate': 'September 10, 2017',
      'code': 'S03E07',
      'characterCount': 0,
      'characters': <Map<String, dynamic>>[],
    };
  }
}
