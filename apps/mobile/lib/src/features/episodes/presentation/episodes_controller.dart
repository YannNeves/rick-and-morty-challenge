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
  List<EpisodeSummary> episodes = const [];
  String? errorMessage;

  Future<void> load({int pageNumber = 1}) async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      page = await _episodeRepository.getEpisodes(page: pageNumber);
      episodes = page!.episodes;
      status = LoadStatus.success;
      notifyListeners();
    } catch (error) {
      status = LoadStatus.failure;
      errorMessage = 'Não foi possível carregar os episódios.';
      notifyListeners();
    }
  }

  Future<void> loadAll() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final allEpisodes = <EpisodeSummary>[
        ...await _episodeRepository.getAllEpisodes(),
      ];

      allEpisodes.sort((first, second) => first.code.compareTo(second.code));
      episodes = List.unmodifiable(allEpisodes);
      page = null;
      status = LoadStatus.success;
      notifyListeners();
    } catch (_) {
      status = LoadStatus.failure;
      errorMessage = 'Não foi possível carregar os episódios.';
      notifyListeners();
    }
  }
}
