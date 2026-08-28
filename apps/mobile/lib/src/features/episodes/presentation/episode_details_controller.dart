import 'package:flutter/foundation.dart';

import '../data/episode_repository.dart';
import '../domain/character_sort.dart';
import '../domain/episode_models.dart';
import 'load_status.dart';

class EpisodeDetailsController extends ChangeNotifier {
  EpisodeDetailsController({
    required int episodeId,
    required EpisodeRepository episodeRepository,
  }) : _episodeId = episodeId,
       _episodeRepository = episodeRepository;

  final int _episodeId;
  final EpisodeRepository _episodeRepository;

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
      notifyListeners();
    } catch (error) {
      status = LoadStatus.failure;
      errorMessage = 'Não foi possível carregar os personagens.';
      notifyListeners();
    }
  }

  Future<void> changeSort(CharacterSortBy value) async {
    if (value == sortBy) {
      return;
    }

    sortBy = value;
    await load();
  }
}
