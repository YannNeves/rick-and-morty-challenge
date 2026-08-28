import '../../../core/network/api_client.dart';
import '../domain/character_sort.dart';
import '../domain/episode_models.dart';

abstract interface class EpisodeRepository {
  Future<EpisodeListPage> getEpisodes({int page = 1});
  Future<List<EpisodeSummary>> getAllEpisodes();

  Future<EpisodeDetails> getEpisodeDetails(
    int episodeId, {
    CharacterSortBy sortBy = CharacterSortBy.name,
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
  Future<EpisodeDetails> getEpisodeDetails(
    int episodeId, {
    CharacterSortBy sortBy = CharacterSortBy.name,
  }) async {
    final json = await _apiClient.getMap(
      '/episodes/$episodeId',
      query: {'sortCharactersBy': sortBy.apiValue, 'characterOrder': 'asc'},
    );

    return EpisodeDetails.fromJson(json);
  }
}
