import '../../../core/network/api_client.dart';
import '../domain/character_sort.dart';
import '../domain/episode_models.dart';

abstract interface class EpisodeRepository {
  Future<EpisodeListPage> getEpisodes({int page = 1});
  Future<List<EpisodeSummary>> getAllEpisodes();
  Future<List<EpisodeSummary>> getEpisodesBatch(List<int> ids);

  Future<EpisodeDetails> getEpisodeDetails(
    int episodeId, {
    CharacterSortBy sortBy = CharacterSortBy.name,
    CharacterSortOrder order = CharacterSortOrder.ascending,
  });
}

class RemoteEpisodeRepository implements EpisodeRepository {
  const RemoteEpisodeRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<EpisodeListPage> getEpisodes({int page = 1}) async {
    final json = await _apiClient.getMap('/episodes', query: {'page': '$page'});

    return EpisodeListPage.fromJson(json);
  }

  @override
  Future<List<EpisodeSummary>> getAllEpisodes() async {
    final json = await _apiClient.getMap('/episodes/all');
    final items = json['episodes'] as List<dynamic>? ?? const [];
    return items
        .map(
          (item) =>
              EpisodeSummary.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
  }

  @override
  Future<List<EpisodeSummary>> getEpisodesBatch(List<int> ids) async {
    if (ids.isEmpty) return const [];
    final json = await _apiClient.getMap(
      '/episodes/batch',
      query: {'ids': ids.join(',')},
    );
    final items = json['episodes'] as List<dynamic>? ?? const [];
    return items
        .map(
          (item) =>
              EpisodeSummary.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
  }

  @override
  Future<EpisodeDetails> getEpisodeDetails(
    int episodeId, {
    CharacterSortBy sortBy = CharacterSortBy.name,
    CharacterSortOrder order = CharacterSortOrder.ascending,
  }) async {
    final json = await _apiClient.getMap(
      '/episodes/$episodeId',
      query: {
        'sortCharactersBy': sortBy.apiValue,
        'characterOrder': order.apiValue,
      },
    );

    return EpisodeDetails.fromJson(json);
  }
}
