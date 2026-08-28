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
  test('orders by season and episode and limits the section to ten', () async {
    final viewModel = HomeViewModel(
      characterRepository: _CharacterRepositoryStub(),
      episodeRepository: _EpisodeRepositoryStub(),
      locationRepository: _LocationRepositoryStub(),
    );

    await viewModel.loadEpisodes();

    expect(viewModel.status, HomeLoadStatus.success);
    expect(viewModel.episodes, hasLength(10));
    expect(viewModel.episodes.first.code, 'S01E01');
    expect(viewModel.episodes.last.code, 'S02E05');
  });

  test(
    'orders locations alphabetically and limits the section to ten',
    () async {
      final viewModel = HomeViewModel(
        characterRepository: _CharacterRepositoryStub(),
        episodeRepository: _EpisodeRepositoryStub(),
        locationRepository: _LocationRepositoryStub(),
      );

      await viewModel.loadLocations();

      expect(viewModel.locationsStatus, HomeLoadStatus.success);
      expect(viewModel.locations, hasLength(10));
      expect(viewModel.locations.first.name, 'Location A');
      expect(viewModel.locations.last.name, 'Location J');
    },
  );

  test(
    'orders characters alphabetically and limits the section to ten',
    () async {
      final viewModel = HomeViewModel(
        characterRepository: _CharacterRepositoryStub(),
        episodeRepository: _EpisodeRepositoryStub(),
        locationRepository: _LocationRepositoryStub(),
      );

      await viewModel.loadCharacters();

      expect(viewModel.charactersStatus, HomeLoadStatus.success);
      expect(viewModel.characters, hasLength(10));
      expect(viewModel.characters.first.name, 'Character A');
      expect(viewModel.characters.last.name, 'Character J');
    },
  );
}

class _CharacterRepositoryStub implements CharacterRepository {
  @override
  Future<CharacterDetails> getCharacterDetails(int id) async =>
      throw UnimplementedError();

  @override
  Future<List<CharacterSummary>> getAllCharacters() async {
    throw UnimplementedError();
  }

  @override
  Future<CharacterListPage> getCharacters({int page = 1}) async {
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
  @override
  Future<List<EpisodeSummary>> getEpisodesBatch(List<int> ids) async =>
      throw UnimplementedError();

  @override
  Future<List<EpisodeSummary>> getAllEpisodes() async {
    throw UnimplementedError();
  }

  @override
  Future<EpisodeListPage> getEpisodes({int page = 1}) async {
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
  }) async {
    throw UnimplementedError();
  }
}

class _LocationRepositoryStub implements LocationRepository {
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
