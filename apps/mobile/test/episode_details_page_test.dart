import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/features/characters/data/character_repository.dart';
import 'package:rick_and_morty_challenge/src/features/characters/domain/character_models.dart'
    as character_models;
import 'package:rick_and_morty_challenge/src/features/episodes/data/episode_repository.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/character_sort.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/episode_models.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/presentation/episode_details_page.dart';
import 'package:rick_and_morty_challenge/src/features/locations/data/location_repository.dart';
import 'package:rick_and_morty_challenge/src/features/locations/domain/location_models.dart';

void main() {
  const episode = EpisodeSummary(
    id: 1,
    name: 'Pilot',
    airDate: 'December 2, 2013',
    code: 'S01E01',
    characterCount: 2,
  );

  testWidgets('renders details, searches and changes character order', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final episodes = _EpisodeRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: EpisodeDetailsPage(
          episode: episode,
          episodeRepository: episodes,
          characterRepository: _CharacterRepository(),
          locationRepository: _LocationRepository(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('PILOT - S01E01'), findsOneWidget);
    expect(find.textContaining('December 2, 2013'), findsOneWidget);
    expect(find.textContaining('Número de personagens:'), findsOneWidget);
    expect(find.text('Personagens'), findsOneWidget);
    expect(find.text('2 encontrados'), findsOneWidget);
    expect(find.text('Morty Smith'), findsOneWidget);
    expect(find.text('Rick Sanchez'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Busque por personagem'),
      'morty',
    );
    await tester.pump();
    expect(find.text('1 encontrados'), findsOneWidget);
    expect(find.text('Morty Smith'), findsOneWidget);
    expect(find.text('Rick Sanchez'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    await tester.tap(find.byTooltip('Filtros e ordenação'));
    await tester.pumpAndSettle();

    expect(find.text('Ordenar por'), findsOneWidget);
    expect(find.text('Ordem'), findsOneWidget);
    await tester.tap(find.text('Espécie'));
    await tester.tap(find.text('Decrescente'));
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    expect(episodes.lastSort, CharacterSortBy.species);
    expect(episodes.lastOrder, CharacterSortOrder.descending);
    expect(find.text('2 encontrados'), findsOneWidget);
  });

  testWidgets('shows an error and retries the details request', (tester) async {
    final episodes = _EpisodeRepository(failuresBeforeSuccess: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: EpisodeDetailsPage(
          episode: episode,
          episodeRepository: episodes,
          characterRepository: _CharacterRepository(),
          locationRepository: _LocationRepository(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Personagens indisponíveis'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pump();

    expect(find.text('Personagens'), findsOneWidget);
    expect(episodes.calls, 2);
  });
}

class _EpisodeRepository implements EpisodeRepository {
  _EpisodeRepository({this.failuresBeforeSuccess = 0});

  final int failuresBeforeSuccess;
  int calls = 0;
  CharacterSortBy? lastSort;
  CharacterSortOrder? lastOrder;

  @override
  Future<EpisodeDetails> getEpisodeDetails(
    int episodeId, {
    CharacterSortBy sortBy = CharacterSortBy.name,
    CharacterSortOrder order = CharacterSortOrder.ascending,
  }) async {
    calls += 1;
    lastSort = sortBy;
    lastOrder = order;
    if (calls <= failuresBeforeSuccess) throw Exception('temporary failure');

    return const EpisodeDetails(
      id: 1,
      name: 'Pilot',
      airDate: 'December 2, 2013',
      code: 'S01E01',
      characterCount: 2,
      characters: [
        CharacterSummary(
          id: 2,
          name: 'Morty Smith',
          status: 'Alive',
          species: 'Human',
          type: '',
          gender: 'Male',
          image: '',
          origin: 'Earth',
          location: 'Earth',
          episodeCount: 40,
        ),
        CharacterSummary(
          id: 1,
          name: 'Rick Sanchez',
          status: 'Alive',
          species: 'Human',
          type: '',
          gender: 'Male',
          image: '',
          origin: 'Earth',
          location: 'Earth',
          episodeCount: 51,
        ),
      ],
    );
  }

  @override
  Future<List<EpisodeSummary>> getAllEpisodes() => throw UnimplementedError();

  @override
  Future<List<EpisodeSummary>> getEpisodesBatch(List<int> ids) =>
      throw UnimplementedError();

  @override
  Future<EpisodeListPage> getEpisodes({int page = 1}) =>
      throw UnimplementedError();
}

class _CharacterRepository implements CharacterRepository {
  @override
  Future<character_models.CharacterDetails> getCharacterDetails(int id) =>
      throw UnimplementedError();

  @override
  Future<character_models.CharacterListPage> getCharacters({
    int page = 1,
    String? name,
    String? status,
    String? species,
  }) => throw UnimplementedError();
}

class _LocationRepository implements LocationRepository {
  @override
  Future<List<LocationSummary>> getAllLocations() => throw UnimplementedError();

  @override
  Future<LocationDetails> getLocationDetails(int id) =>
      throw UnimplementedError();

  @override
  Future<LocationListPage> getLocations({int page = 1}) =>
      throw UnimplementedError();

  @override
  Future<List<LocationSummary>> getLocationsBatch(List<int> ids) =>
      throw UnimplementedError();
}
