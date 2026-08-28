import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../analytics/analytics_tracker.dart';
import '../data/episode_repository.dart';
import '../domain/episode_models.dart';
import 'load_status.dart';

class EpisodesController extends ChangeNotifier {
  EpisodesController({
    required EpisodeRepository episodeRepository,
    required AnalyticsTracker analyticsTracker,
  }) : _episodeRepository = episodeRepository,
       _analyticsTracker = analyticsTracker;

  final EpisodeRepository _episodeRepository;
  final AnalyticsTracker _analyticsTracker;

  LoadStatus status = LoadStatus.idle;
  EpisodeListPage? page;
  String? errorMessage;

  Future<void> load({int pageNumber = 1}) async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      page = await _episodeRepository.getEpisodes(page: pageNumber);
      status = LoadStatus.success;
      notifyListeners();
      unawaited(
        _analyticsTracker.track(
          'episode_list_viewed',
          properties: {'page': pageNumber},
        ),
      );
    } catch (error) {
      status = LoadStatus.failure;
      errorMessage = 'Não foi possível carregar os episódios.';
      notifyListeners();
    }
  }
}
