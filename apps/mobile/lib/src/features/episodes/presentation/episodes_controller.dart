import 'package:flutter/foundation.dart';

import '../data/episode_repository.dart';
import '../domain/episode_models.dart';
import 'load_status.dart';

class EpisodesController extends ChangeNotifier {
  EpisodesController({required EpisodeRepository episodeRepository})
    : _episodeRepository = episodeRepository;

  final EpisodeRepository _episodeRepository;

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
    } catch (error) {
      status = LoadStatus.failure;
      errorMessage = 'Não foi possível carregar os episódios.';
      notifyListeners();
    }
  }
}
