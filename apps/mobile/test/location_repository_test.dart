import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/core/network/api_client.dart';
import 'package:rick_and_morty_challenge/src/features/locations/data/location_repository.dart';

void main() {
  test(
    'location repository parses paginated and complete collections',
    () async {
      final client = _LocationApiClient();
      final repository = RemoteLocationRepository(client);

      final page = await repository.getLocations(page: 2);
      expect(client.lastPath, '/locations');
      expect(client.lastQuery, {'page': '2'});
      expect(page.locations.single.name, 'Earth (C-137)');

      final all = await repository.getAllLocations();
      expect(client.lastPath, '/locations/all');
      expect(all.single.residentCount, 2);
    },
  );

  test(
    'location repository skips empty batches and parses batch results',
    () async {
      final client = _LocationApiClient();
      final repository = RemoteLocationRepository(client);

      expect(await repository.getLocationsBatch([]), isEmpty);
      expect(client.calls, 0);

      final locations = await repository.getLocationsBatch([1, 3]);
      expect(client.lastPath, '/locations/batch');
      expect(client.lastQuery, {'ids': '1,3'});
      expect(locations.single.id, 1);
    },
  );

  test('location repository parses residents in location details', () async {
    final client = _LocationApiClient();
    final details = await RemoteLocationRepository(
      client,
    ).getLocationDetails(1);

    expect(client.lastPath, '/locations/1');
    expect(details.residents.single.name, 'Rick Sanchez');
    expect(details.dimension, 'Dimension C-137');
  });
}

class _LocationApiClient implements ApiClient {
  String? lastPath;
  Map<String, String>? lastQuery;
  int calls = 0;

  @override
  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, String>? query,
  }) async {
    calls += 1;
    lastPath = path;
    lastQuery = query;
    if (path == '/locations') {
      return {
        'page': 2,
        'totalPages': 7,
        'totalItems': 126,
        'hasNextPage': true,
        'hasPreviousPage': true,
        'locations': [_locationJson],
      };
    }
    if (path == '/locations/1') {
      return {
        ..._locationJson,
        'residents': [_characterJson],
      };
    }
    return {
      'locations': [_locationJson],
    };
  }
}

const _locationJson = <String, dynamic>{
  'id': 1,
  'name': 'Earth (C-137)',
  'type': 'Planet',
  'dimension': 'Dimension C-137',
  'residentCount': 2,
};

const _characterJson = <String, dynamic>{
  'id': 1,
  'name': 'Rick Sanchez',
  'status': 'Alive',
  'species': 'Human',
  'type': '',
  'gender': 'Male',
  'image': '',
  'origin': 'Earth (C-137)',
  'location': 'Citadel of Ricks',
  'episodeCount': 51,
};
