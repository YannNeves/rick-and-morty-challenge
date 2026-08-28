import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/data/episode_repository.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/character_sort.dart';
import 'package:rick_and_morty_challenge/src/features/episodes/domain/episode_models.dart';
import 'package:rick_and_morty_challenge/src/features/home/ui/view_models/home_view_model.dart';

void main() {
  test('orders by season and episode and limits the section to ten', () async {
    final viewModel = HomeViewModel(
      episodeRepository: _EpisodeRepositoryStub(),
    );

    await viewModel.loadEpisodes();

    expect(viewModel.status, HomeLoadStatus.success);
    expect(viewModel.episodes, hasLength(10));
    expect(viewModel.episodes.first.code, 'S01E01');
    expect(viewModel.episodes.last.code, 'S02E05');
  });
}

class _EpisodeRepositoryStub implements EpisodeRepository {
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
