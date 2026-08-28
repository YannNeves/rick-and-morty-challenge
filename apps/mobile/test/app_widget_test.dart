import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/app/app.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/data/episode_repository.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/character_sort.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/episode_models.dart';

void main() {
  testWidgets('shows home episodes and navigates between destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      RickAndMortyApp(episodeRepository: FakeEpisodeRepository()),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('episodes-section-title')),
      findsOneWidget,
    );
    expect(find.text('A Episode | S01E02'), findsOneWidget);
    expect(find.byKey(const ValueKey('global-search-field')), findsOneWidget);

    await tester.tap(find.text('Planetas'));
    await tester.pumpAndSettle();

    expect(find.text('Rota Planetas'), findsOneWidget);
  });

  testWidgets('toggles between dark and light themes', (tester) async {
    await tester.pumpWidget(
      RickAndMortyApp(episodeRepository: FakeEpisodeRepository()),
    );

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await tester.tap(find.byKey(const ValueKey('theme-toggle')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });
}

class FakeEpisodeRepository implements EpisodeRepository {
  @override
  Future<EpisodeListPage> getEpisodes({int page = 1}) async {
    return EpisodeListPage(
      page: page,
      totalPages: 1,
      totalItems: 2,
      hasNextPage: false,
      hasPreviousPage: false,
      episodes: const [
        EpisodeSummary(
          id: 1,
          name: 'Z Episode',
          airDate: 'December 2, 2013',
          code: 'S01E01',
          characterCount: 1,
        ),
        EpisodeSummary(
          id: 2,
          name: 'A Episode',
          airDate: 'December 9, 2013',
          code: 'S01E02',
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
    throw UnimplementedError();
  }
}
