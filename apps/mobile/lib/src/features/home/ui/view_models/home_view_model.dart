import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../episodes/data/episode_repository.dart';
import '../../../episodes/domain/episode_models.dart';

enum HomeLoadStatus { initial, loading, success, empty, failure }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required EpisodeRepository episodeRepository})
    : _episodeRepository = episodeRepository;

  static const episodeLimit = 10;

  final EpisodeRepository _episodeRepository;

  HomeLoadStatus _status = HomeLoadStatus.initial;
  List<EpisodeSummary> _episodes = const [];
  String? _errorMessage;

  HomeLoadStatus get status => _status;
  UnmodifiableListView<EpisodeSummary> get episodes =>
      UnmodifiableListView(_episodes);
  String? get errorMessage => _errorMessage;

  Future<void> loadEpisodes() async {
    _status = HomeLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final page = await _episodeRepository.getEpisodes();
      final ordered = [...page.episodes]..sort(_compareBySeasonAndEpisode);

      _episodes = List.unmodifiable(ordered.take(episodeLimit));
      _status =
          _episodes.isEmpty ? HomeLoadStatus.empty : HomeLoadStatus.success;
    } on Exception catch (error) {
      _episodes = const [];
      _errorMessage = error.toString();
      _status = HomeLoadStatus.failure;
    }

    notifyListeners();
  }

  static int _compareBySeasonAndEpisode(
    EpisodeSummary left,
    EpisodeSummary right,
  ) {
    final leftOrder = _episodeOrder(left.code);
    final rightOrder = _episodeOrder(right.code);
    final seasonComparison = leftOrder.$1.compareTo(rightOrder.$1);

    if (seasonComparison != 0) return seasonComparison;

    final episodeComparison = leftOrder.$2.compareTo(rightOrder.$2);
    if (episodeComparison != 0) return episodeComparison;

    return left.id.compareTo(right.id);
  }

  static (int, int) _episodeOrder(String code) {
    final match = RegExp(
      r'^S(\d+)E(\d+)$',
      caseSensitive: false,
    ).firstMatch(code.trim());

    if (match == null) return (1 << 31, 1 << 31);

    return (int.parse(match.group(1)!), int.parse(match.group(2)!));
  }
}
