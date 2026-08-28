import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/data/episode_repository.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/character_sort.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/episode_models.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/presentation/episode_details_controller.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/presentation/load_status.dart';

void main() {
  test('EpisodeDetailsController loads episode characters', () async {
    final controller = EpisodeDetailsController(
      episodeId: 1,
      episodeRepository: FakeEpisodeRepository(),
    );

    await controller.load();

    expect(controller.status, LoadStatus.success);
    expect(controller.details?.characters.single.name, 'Rick Sanchez');
  });
}

class FakeEpisodeRepository implements EpisodeRepository {
  @override
  Future<List<EpisodeSummary>> getEpisodesBatch(List<int> ids) async =>
      throw UnimplementedError();

  @override
  Future<List<EpisodeSummary>> getAllEpisodes() async {
    throw UnimplementedError();
  }

  @override
  Future<EpisodeListPage> getEpisodes({int page = 1}) async =>
      throw UnimplementedError();

  @override
  Future<EpisodeDetails> getEpisodeDetails(
    int episodeId, {
    CharacterSortBy sortBy = CharacterSortBy.name,
    CharacterSortOrder order = CharacterSortOrder.ascending,
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
          image: '',
          origin: 'Earth',
          location: 'Earth',
          episodeCount: 51,
        ),
      ],
    );
  }
}
