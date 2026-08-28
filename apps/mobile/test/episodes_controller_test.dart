import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/data/episode_repository.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/character_sort.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/episode_models.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/presentation/episodes_controller.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/presentation/load_status.dart';

void main() {
  test('EpisodesController loads episodes', () async {
    final controller = EpisodesController(
      episodeRepository: FakeEpisodeRepository(),
    );

    await controller.load(pageNumber: 1);

    expect(controller.status, LoadStatus.success);
    expect(controller.page?.episodes.single.name, 'Pilot');
  });
}

class FakeEpisodeRepository implements EpisodeRepository {
  @override
  Future<List<EpisodeSummary>> getEpisodesBatch(List<int> ids) async =>
      throw UnimplementedError();

  @override
  Future<List<EpisodeSummary>> getAllEpisodes() async {
    return (await getEpisodes()).episodes;
  }

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
    CharacterSortOrder order = CharacterSortOrder.ascending,
  }) async {
    throw UnimplementedError();
  }
}
