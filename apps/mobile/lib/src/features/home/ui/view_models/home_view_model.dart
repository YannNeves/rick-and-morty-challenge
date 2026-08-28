import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../characters/data/character_repository.dart';
import '../../../characters/domain/character_models.dart';
import '../../../episodes/data/episode_repository.dart';
import '../../../episodes/domain/episode_models.dart' hide CharacterSummary;
import '../../../locations/data/location_repository.dart';
import '../../../locations/domain/location_models.dart';

enum HomeLoadStatus { initial, loading, success, empty, failure }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required CharacterRepository characterRepository,
    required EpisodeRepository episodeRepository,
    required LocationRepository locationRepository,
  }) : _characterRepository = characterRepository,
       _episodeRepository = episodeRepository,
       _locationRepository = locationRepository;

  static const characterLimit = 10;
  static const episodeLimit = 10;
  static const locationLimit = 10;

  final CharacterRepository _characterRepository;
  final EpisodeRepository _episodeRepository;
  final LocationRepository _locationRepository;

  HomeLoadStatus _status = HomeLoadStatus.initial;
  List<EpisodeSummary> _episodes = const [];
  String? _errorMessage;
  HomeLoadStatus _locationsStatus = HomeLoadStatus.initial;
  List<LocationSummary> _locations = const [];
  String? _locationsErrorMessage;
  HomeLoadStatus _charactersStatus = HomeLoadStatus.initial;
  List<CharacterSummary> _characters = const [];
  String? _charactersErrorMessage;

  HomeLoadStatus get status => _status;
  UnmodifiableListView<EpisodeSummary> get episodes =>
      UnmodifiableListView(_episodes);
  String? get errorMessage => _errorMessage;
  HomeLoadStatus get locationsStatus => _locationsStatus;
  UnmodifiableListView<LocationSummary> get locations =>
      UnmodifiableListView(_locations);
  String? get locationsErrorMessage => _locationsErrorMessage;
  HomeLoadStatus get charactersStatus => _charactersStatus;
  UnmodifiableListView<CharacterSummary> get characters =>
      UnmodifiableListView(_characters);
  String? get charactersErrorMessage => _charactersErrorMessage;

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

  Future<void> loadLocations() async {
    _locationsStatus = HomeLoadStatus.loading;
    _locationsErrorMessage = null;
    notifyListeners();

    try {
      final page = await _locationRepository.getLocations();
      final ordered = [...page.locations]..sort(
        (left, right) =>
            left.name.toLowerCase().compareTo(right.name.toLowerCase()),
      );

      _locations = List.unmodifiable(ordered.take(locationLimit));
      _locationsStatus =
          _locations.isEmpty ? HomeLoadStatus.empty : HomeLoadStatus.success;
    } on Exception catch (error) {
      _locations = const [];
      _locationsErrorMessage = error.toString();
      _locationsStatus = HomeLoadStatus.failure;
    }

    notifyListeners();
  }

  Future<void> loadCharacters() async {
    _charactersStatus = HomeLoadStatus.loading;
    _charactersErrorMessage = null;
    notifyListeners();

    try {
      final page = await _characterRepository.getCharacters();
      final ordered = [...page.characters]..sort(
        (left, right) =>
            left.name.toLowerCase().compareTo(right.name.toLowerCase()),
      );

      _characters = List.unmodifiable(ordered.take(characterLimit));
      _charactersStatus =
          _characters.isEmpty ? HomeLoadStatus.empty : HomeLoadStatus.success;
    } on Exception catch (error) {
      _characters = const [];
      _charactersErrorMessage = error.toString();
      _charactersStatus = HomeLoadStatus.failure;
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
