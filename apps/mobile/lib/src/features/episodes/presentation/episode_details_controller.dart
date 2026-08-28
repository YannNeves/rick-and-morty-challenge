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
  CharacterSortOrder sortOrder = CharacterSortOrder.ascending;
  String? errorMessage;

  Future<void> load() async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      details = await _episodeRepository.getEpisodeDetails(
        _episodeId,
        sortBy: sortBy,
        order: sortOrder,
      );
      status = LoadStatus.success;
      notifyListeners();
    } catch (error) {
      status = LoadStatus.failure;
      errorMessage = 'Não foi possível carregar os personagens.';
      notifyListeners();
    }
  }

  Future<void> changeSort(
    CharacterSortBy value,
    CharacterSortOrder order,
  ) async {
    if (value == sortBy && order == sortOrder) {
      return;
    }

    sortBy = value;
    sortOrder = order;
    await load();
  }
}
