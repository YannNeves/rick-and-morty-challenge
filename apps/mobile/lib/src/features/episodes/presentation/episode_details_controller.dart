import 'package:flutter/foundation.dart';

import '../../analytics/analytics_tracker.dart';
import '../data/episode_repository.dart';
import '../domain/character_sort.dart';
import '../domain/episode_models.dart';
import 'load_status.dart';

class EpisodeDetailsController extends ChangeNotifier {
  EpisodeDetailsController({
    required int episodeId,
    required EpisodeRepository episodeRepository,
    required AnalyticsTracker analyticsTracker,
  }) : _episodeId = episodeId,
       _episodeRepository = episodeRepository,
       _analyticsTracker = analyticsTracker;

  final int _episodeId;
  final EpisodeRepository _episodeRepository;
  final AnalyticsTracker _analyticsTracker;

  LoadStatus status = LoadStatus.idle;
  EpisodeDetails? details;
  CharacterSortBy sortBy = CharacterSortBy.name;
  String? errorMessage;

  Future<void> load() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      details = await _episodeRepository.getEpisodeDetails(
        _episodeId,
        sortBy: sortBy,
      );
      status = LoadStatus.success;
      await _analyticsTracker.track(
        'episode_details_viewed',
        properties: {'episodeId': _episodeId, 'sortBy': sortBy.apiValue},
      );
    } catch (error) {
      status = LoadStatus.failure;
      errorMessage = 'Não foi possível carregar os personagens.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> changeSort(CharacterSortBy value) async {
    if (value == sortBy) {
      return;
    }

    sortBy = value;
    await _analyticsTracker.track(
      'character_sort_changed',
      properties: {'episodeId': _episodeId, 'sortBy': value.apiValue},
    );
    await load();
  }
}
