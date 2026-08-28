import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/features/characters/data/character_repository.dart';
import 'package:rick_and_morty_challenge/src/features/characters/domain/character_models.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/data/episode_repository.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/character_sort.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/episode_models.dart'
    hide CharacterSummary;
import 'package:rick_and_morty_challenge/src/features/home/ui/view_models/home_view_model.dart';
import 'package:rick_and_morty_challenge/src/features/locations/data/location_repository.dart';
import 'package:rick_and_morty_challenge/src/features/locations/domain/location_models.dart';

void main() {
  test('orders the complete first page by season and episode', () async {
    final viewModel = HomeViewModel(
      characterRepository: _CharacterRepositoryStub(),
      episodeRepository: _EpisodeRepositoryStub(),
      locationRepository: _LocationRepositoryStub(),
    );

    await viewModel.loadEpisodes();

    expect(viewModel.status, HomeLoadStatus.success);
    expect(viewModel.episodes, hasLength(12));
    expect(viewModel.episodes.first.code, 'S01E01');
    expect(viewModel.episodes.last.code, 'S03E01');
  });

  test('orders the complete first page of locations alphabetically', () async {
    final viewModel = HomeViewModel(
      characterRepository: _CharacterRepositoryStub(),
      episodeRepository: _EpisodeRepositoryStub(),
      locationRepository: _LocationRepositoryStub(),
    );

    await viewModel.loadLocations();

    expect(viewModel.locationsStatus, HomeLoadStatus.success);
    expect(viewModel.locations, hasLength(12));
    expect(viewModel.locations.first.name, 'Location A');
    expect(viewModel.locations.last.name, 'Location L');
  });

  test('orders the complete first page of characters alphabetically', () async {
    final viewModel = HomeViewModel(
      characterRepository: _CharacterRepositoryStub(),
      episodeRepository: _EpisodeRepositoryStub(),
      locationRepository: _LocationRepositoryStub(),
    );

    await viewModel.loadCharacters();

    expect(viewModel.charactersStatus, HomeLoadStatus.success);
    expect(viewModel.characters, hasLength(12));
    expect(viewModel.characters.first.name, 'Character A');
    expect(viewModel.characters.last.name, 'Character L');
  });

  test('loads and reorders the next home page for every section', () async {
    final viewModel = HomeViewModel(
      characterRepository: _CharacterRepositoryStub(paginated: true),
      episodeRepository: _EpisodeRepositoryStub(paginated: true),
      locationRepository: _LocationRepositoryStub(paginated: true),
    );

    await Future.wait([
      viewModel.loadEpisodes(),
      viewModel.loadLocations(),
      viewModel.loadCharacters(),
    ]);
    await Future.wait([
      viewModel.loadMoreEpisodes(),
      viewModel.loadMoreLocations(),
      viewModel.loadMoreCharacters(),
    ]);

    expect(viewModel.episodes.map((item) => item.code), ['S01E01', 'S02E01']);
    expect(viewModel.locations.map((item) => item.name), [
      'Location A',
      'Location B',
    ]);
    expect(viewModel.characters.map((item) => item.name), [
      'Character A',
      'Character B',
    ]);
    expect(viewModel.hasMoreEpisodes, isFalse);
    expect(viewModel.hasMoreLocations, isFalse);
    expect(viewModel.hasMoreCharacters, isFalse);
  });

  test('preserves home characters when loading the next page fails', () async {
    final viewModel = HomeViewModel(
      characterRepository: _CharacterRepositoryStub(
        paginated: true,
        failSecondPage: true,
      ),
      episodeRepository: _EpisodeRepositoryStub(),
      locationRepository: _LocationRepositoryStub(),
    );

    await viewModel.loadCharacters();
    await viewModel.loadMoreCharacters();

    expect(viewModel.characters.single.name, 'Character B');
    expect(viewModel.charactersStatus, HomeLoadStatus.success);
    expect(viewModel.moreCharactersError, isNotNull);
  });
}

class _CharacterRepositoryStub implements CharacterRepository {
  _CharacterRepositoryStub({
    this.paginated = false,
    this.failSecondPage = false,
  });

  final bool paginated;
  final bool failSecondPage;

  @override
  Future<CharacterDetails> getCharacterDetails(int id) async =>
      throw UnimplementedError();

  @override
  Future<CharacterListPage> getCharacters({
    int page = 1,
    String? name,
    String? status,
    String? species,
  }) async {
    if (failSecondPage && page == 2) throw Exception('rate limited');
    if (paginated) {
      final name = page == 1 ? 'Character B' : 'Character A';
      return CharacterListPage(
        page: page,
        totalPages: 2,
        totalItems: 2,
        hasNextPage: page == 1,
        hasPreviousPage: page > 1,
        characters: [
          CharacterSummary(
            id: page,
            name: name,
            status: 'Alive',
            species: 'Human',
            type: '',
            gender: 'Unknown',
            image: '',
            origin: 'Earth',
            location: 'Earth',
            episodeCount: 1,
          ),
        ],
      );
    }

    final characters = List.generate(12, (index) {
      final letter = String.fromCharCode('L'.codeUnitAt(0) - index);
      return CharacterSummary(
        id: index + 1,
        name: 'Character $letter',
        status: 'Alive',
        species: 'Human',
        type: '',
        gender: 'Unknown',
        image: 'https://example.com/character.png',
        origin: 'Earth',
        location: 'Earth',
        episodeCount: 1,
      );
    });

    return CharacterListPage(
      page: page,
      totalPages: 1,
      totalItems: characters.length,
      hasNextPage: false,
      hasPreviousPage: false,
      characters: characters,
    );
  }
}

class _EpisodeRepositoryStub implements EpisodeRepository {
  _EpisodeRepositoryStub({this.paginated = false});

  final bool paginated;

  @override
  Future<List<EpisodeSummary>> getEpisodesBatch(List<int> ids) async =>
      throw UnimplementedError();

  @override
  Future<List<EpisodeSummary>> getAllEpisodes() async {
    throw UnimplementedError();
  }

  @override
  Future<EpisodeListPage> getEpisodes({int page = 1}) async {
    if (paginated) {
      final code = page == 1 ? 'S02E01' : 'S01E01';
      return EpisodeListPage(
        page: page,
        totalPages: 2,
        totalItems: 2,
        hasNextPage: page == 1,
        hasPreviousPage: page > 1,
        episodes: [
          EpisodeSummary(
            id: page,
            name: 'Episode $code',
            airDate: 'Date',
            code: code,
            characterCount: 1,
          ),
        ],
      );
    }

    const codes = [
      'S02E06',
      'S01E03',
      'S02E02',
      'S01E01',
      'S02E05',
      'S01E02',
      'S02E01',
      'S01E05',
      'S02E04',
      'S01E04',
      'S02E03',
      'S03E01',
    ];
    final episodes =
        codes.indexed.map((entry) {
          return EpisodeSummary(
            id: entry.$1 + 1,
            name: 'Episode ${entry.$2}',
            airDate: 'Date',
            code: entry.$2,
            characterCount: 1,
          );
        }).toList();

    return EpisodeListPage(
      page: page,
      totalPages: 1,
      totalItems: episodes.length,
      hasNextPage: false,
      hasPreviousPage: false,
      episodes: episodes,
    );
  }

  @override
  Future<EpisodeDetails> getEpisodeDetails(
    int episodeId, {
    CharacterSortBy sortBy = CharacterSortBy.name,
    CharacterSortOrder order = CharacterSortOrder.ascending,
  }) async {
    throw UnimplementedError();
  }
}

class _LocationRepositoryStub implements LocationRepository {
  _LocationRepositoryStub({this.paginated = false});

  final bool paginated;

  @override
  Future<List<LocationSummary>> getLocationsBatch(List<int> ids) async =>
      throw UnimplementedError();

  @override
  Future<List<LocationSummary>> getAllLocations() async {
    throw UnimplementedError();
  }

  @override
  Future<LocationDetails> getLocationDetails(int id) async {
    throw UnimplementedError();
  }

  @override
  Future<LocationListPage> getLocations({int page = 1}) async {
    if (paginated) {
      final name = page == 1 ? 'Location B' : 'Location A';
      return LocationListPage(
        page: page,
        totalPages: 2,
        totalItems: 2,
        hasNextPage: page == 1,
        hasPreviousPage: page > 1,
        locations: [
          LocationSummary(
            id: page,
            name: name,
            type: 'Planet',
            dimension: 'Dimension',
            residentCount: 1,
          ),
        ],
      );
    }

    final locations = List.generate(12, (index) {
      final letter = String.fromCharCode('L'.codeUnitAt(0) - index);
      return LocationSummary(
        id: index + 1,
        name: 'Location $letter',
        type: 'Planet',
        dimension: 'Dimension',
        residentCount: 1,
      );
    });

    return LocationListPage(
      page: page,
      totalPages: 1,
      totalItems: locations.length,
      hasNextPage: false,
      hasPreviousPage: false,
      locations: locations,
    );
  }
}
