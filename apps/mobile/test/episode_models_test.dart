import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/episode_models.dart';

void main() {
  test('EpisodeListPage parses the API contract', () {
    final page = EpisodeListPage.fromJson({
      'page': 1,
      'totalPages': 3,
      'totalItems': 51,
      'hasNextPage': true,
      'hasPreviousPage': false,
      'episodes': [
        {
          'id': 1,
          'name': 'Pilot',
          'airDate': 'December 2, 2013',
          'code': 'S01E01',
          'characterCount': 19,
        },
      ],
    });

    expect(page.totalItems, 51);
    expect(page.episodes.single.code, 'S01E01');
  });

  test('EpisodeDetails parses sorted characters', () {
    final details = EpisodeDetails.fromJson({
      'id': 28,
      'name': 'The Ricklantis Mixup',
      'airDate': 'September 10, 2017',
      'code': 'S03E07',
      'characterCount': 2,
      'characters': [
        {
          'id': 2,
          'name': 'Morty Smith',
          'status': 'Alive',
          'species': 'Human',
          'type': '',
          'gender': 'Male',
          'image': 'https://example.com/morty.png',
          'origin': 'Earth',
          'location': 'Earth',
          'episodeCount': 51,
        },
      ],
    });

    expect(details.characters.single.name, 'Morty Smith');
    expect(details.characterCount, 2);
  });
}
