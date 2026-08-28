import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/app/app.dart';
import 'package:rick_and_morty_challenge/src/features/characters/data/character_repository.dart';
import 'package:rick_and_morty_challenge/src/features/characters/domain/character_models.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/data/episode_repository.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/character_sort.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/episode_models.dart'
    hide CharacterSummary;
import 'package:rick_and_morty_challenge/src/features/locations/data/location_repository.dart';
import 'package:rick_and_morty_challenge/src/features/locations/domain/location_models.dart';

void main() {
  testWidgets('shows home episodes and navigates between destinations', (
    tester,
  ) async {
    await tester.pumpWidget(
      RickAndMortyApp(
        characterRepository: FakeCharacterRepository(),
        episodeRepository: FakeEpisodeRepository(),
        locationRepository: FakeLocationRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('episodes-section-title')),
      findsOneWidget,
    );
    expect(find.text('A Episode | S01E02'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('locations-section-title')),
      findsOneWidget,
    );
    expect(find.text('Earth (C-137)'), findsNWidgets(2));
    expect(
      find.byKey(const ValueKey('characters-section-title')),
      findsOneWidget,
    );
    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.byKey(const ValueKey('global-search-field')), findsNothing);

    await tester.tap(find.text('Ver todos').at(1));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('locations-page-list')), findsOneWidget);
    expect(find.byKey(const ValueKey('global-search-field')), findsOneWidget);
    expect(find.text('Busque por localização'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('global-search-field')),
      'Citadel',
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('locations-no-search-results')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('global-search-field')),
      'Earth',
    );
    await tester.pumpAndSettle();

    expect(find.text('Earth (C-137)'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Localização'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('locations-page-list')), findsOneWidget);

    await tester.tap(find.text('Episódios'));
    await tester.pumpAndSettle();

    expect(find.text('Busque por episódio'), findsOneWidget);
    expect(find.byKey(const ValueKey('episodes-page-list')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('global-search-field')),
      'S01E02',
    );
    await tester.pumpAndSettle();

    expect(find.text('A Episode'), findsOneWidget);
    expect(find.text('Z Episode'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('global-search-field')),
      'Unknown',
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('episodes-no-search-results')),
      findsOneWidget,
    );

    await tester.tap(find.text('Personagens'));
    await tester.pumpAndSettle();

    expect(find.text('Busque por personagem'), findsOneWidget);
    expect(find.byKey(const ValueKey('characters-page-list')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('global-search-field')),
      'Rick',
    );
    await tester.pumpAndSettle();

    expect(find.text('Rick Sanchez'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('global-search-field')),
      'Morty',
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('characters-no-search-results')),
      findsOneWidget,
    );
  });

  testWidgets('toggles between dark and light themes', (tester) async {
    await tester.pumpWidget(
      RickAndMortyApp(
        characterRepository: FakeCharacterRepository(),
        episodeRepository: FakeEpisodeRepository(),
        locationRepository: FakeLocationRepository(),
      ),
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

class FakeCharacterRepository implements CharacterRepository {
  @override
  Future<CharacterListPage> getCharacters({int page = 1}) async {
    return CharacterListPage(
      page: page,
      totalPages: 1,
      totalItems: 1,
      hasNextPage: false,
      hasPreviousPage: false,
      characters: const [
        CharacterSummary(
          id: 1,
          name: 'Rick Sanchez',
          status: 'Alive',
          species: 'Human',
          type: '',
          gender: 'Male',
          image: 'https://example.com/rick.png',
          origin: 'Earth (C-137)',
          location: 'Citadel of Ricks',
          episodeCount: 51,
        ),
      ],
    );
  }
}

class FakeLocationRepository implements LocationRepository {
  @override
  Future<LocationListPage> getLocations({int page = 1}) async {
    return LocationListPage(
      page: page,
      totalPages: 1,
      totalItems: 1,
      hasNextPage: false,
      hasPreviousPage: false,
      locations: const [
        LocationSummary(
          id: 1,
          name: 'Earth (C-137)',
          type: 'Planet',
          dimension: 'Dimension C-137',
          residentCount: 27,
        ),
      ],
    );
  }
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
