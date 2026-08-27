import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/app/app.dart';
import 'package:rick_and_morty_challenge/src/features/analytics/analytics_tracker.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/data/episode_repository.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/character_sort.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/episode_models.dart';

void main() {
  testWidgets('shows episodes and opens character details', (tester) async {
    await tester.pumpWidget(
      RickAndMortyApp(
        episodeRepository: FakeEpisodeRepository(),
        analyticsTracker: const NoopAnalyticsTracker(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pilot'), findsOneWidget);

    await tester.tap(find.text('Pilot'));
    await tester.pumpAndSettle();

    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Nome'), findsOneWidget);
  });
}

class FakeEpisodeRepository implements EpisodeRepository {
  @override
  Future<EpisodeListPage> getEpisodes({int page = 1}) async {
    return EpisodeListPage(
      page: page,
      totalPages: 1,
      totalItems: 1,
      hasNextPage: false,
      hasPreviousPage: false,
      episodes: const [
        EpisodeSummary(
          id: 1,
          name: 'Pilot',
          airDate: 'December 2, 2013',
          code: 'S01E01',
          characterCount: 1,
        ),
      ],
    );
  }

  @override
  Future<EpisodeDetails> getEpisodeDetails(
    int episodeId, {
    CharacterSortBy sortBy = CharacterSortBy.name,
  }) async {
    return const EpisodeDetails(
      id: 1,
      name: 'Pilot',
      airDate: 'December 2, 2013',
      code: 'S01E01',
      characterCount: 1,
      characters: [
        CharacterSummary(
          id: 1,
          name: 'Rick Sanchez',
          status: 'Alive',
          species: 'Human',
          type: '',
          gender: 'Male',
          image: 'https://example.com/rick.png',
          origin: 'Earth',
          location: 'Earth',
          episodeCount: 51,
        ),
      ],
    );
  }
}
