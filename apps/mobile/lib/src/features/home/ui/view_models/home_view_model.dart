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
  int _episodePage = 0;
  int _locationPage = 0;
  int _characterPage = 0;
  bool _hasMoreEpisodes = true;
  bool _hasMoreLocations = true;
  bool _hasMoreCharacters = true;
  bool _isLoadingMoreEpisodes = false;
  bool _isLoadingMoreLocations = false;
  bool _isLoadingMoreCharacters = false;
  String? _moreEpisodesError;
  String? _moreLocationsError;
  String? _moreCharactersError;

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
  bool get hasMoreEpisodes => _hasMoreEpisodes;
  bool get hasMoreLocations => _hasMoreLocations;
  bool get hasMoreCharacters => _hasMoreCharacters;
  bool get isLoadingMoreEpisodes => _isLoadingMoreEpisodes;
  bool get isLoadingMoreLocations => _isLoadingMoreLocations;
  bool get isLoadingMoreCharacters => _isLoadingMoreCharacters;
  String? get moreEpisodesError => _moreEpisodesError;
  String? get moreLocationsError => _moreLocationsError;
  String? get moreCharactersError => _moreCharactersError;

  Future<void> loadEpisodes() async {
    _episodePage = 0;
    _hasMoreEpisodes = true;
    _episodes = const [];
    _status = HomeLoadStatus.loading;
    _errorMessage = null;
    _moreEpisodesError = null;
    notifyListeners();

    await _loadEpisodesPage();
  }

  Future<void> _loadEpisodesPage() async {
    try {
      final page = await _episodeRepository.getEpisodes(page: _episodePage + 1);
      final ordered = [..._episodes, ...page.episodes]
        ..sort(_compareBySeasonAndEpisode);

      _episodePage = page.page;
      _hasMoreEpisodes = page.hasNextPage;
      _episodes = List.unmodifiable(ordered);
      _status =
          _episodes.isEmpty ? HomeLoadStatus.empty : HomeLoadStatus.success;
    } on Exception catch (error) {
      if (_episodes.isEmpty) {
        _errorMessage = error.toString();
        _status = HomeLoadStatus.failure;
      } else {
        _moreEpisodesError = 'Não foi possível carregar mais episódios.';
      }
    }

    notifyListeners();
  }

  Future<void> loadMoreEpisodes() async {
    if (!_hasMoreEpisodes ||
        _isLoadingMoreEpisodes ||
        _moreEpisodesError != null) {
      return;
    }
    _isLoadingMoreEpisodes = true;
    notifyListeners();
    await _loadEpisodesPage();
    _isLoadingMoreEpisodes = false;
    notifyListeners();
  }

  Future<void> retryMoreEpisodes() async {
    _moreEpisodesError = null;
    await loadMoreEpisodes();
  }

  Future<void> loadLocations() async {
    _locationPage = 0;
    _hasMoreLocations = true;
    _locations = const [];
    _locationsStatus = HomeLoadStatus.loading;
    _locationsErrorMessage = null;
    _moreLocationsError = null;
    notifyListeners();

    await _loadLocationsPage();
  }

  Future<void> _loadLocationsPage() async {
    try {
      final page = await _locationRepository.getLocations(
        page: _locationPage + 1,
      );
      final ordered = [..._locations, ...page.locations]..sort(
        (left, right) =>
            left.name.toLowerCase().compareTo(right.name.toLowerCase()),
      );

      _locationPage = page.page;
      _hasMoreLocations = page.hasNextPage;
      _locations = List.unmodifiable(ordered);
      _locationsStatus =
          _locations.isEmpty ? HomeLoadStatus.empty : HomeLoadStatus.success;
    } on Exception catch (error) {
      if (_locations.isEmpty) {
        _locationsErrorMessage = error.toString();
        _locationsStatus = HomeLoadStatus.failure;
      } else {
        _moreLocationsError = 'Não foi possível carregar mais localizações.';
      }
    }

    notifyListeners();
  }

  Future<void> loadMoreLocations() async {
    if (!_hasMoreLocations ||
        _isLoadingMoreLocations ||
        _moreLocationsError != null) {
      return;
    }
    _isLoadingMoreLocations = true;
    notifyListeners();
    await _loadLocationsPage();
    _isLoadingMoreLocations = false;
    notifyListeners();
  }

  Future<void> retryMoreLocations() async {
    _moreLocationsError = null;
    await loadMoreLocations();
  }

  Future<void> loadCharacters() async {
    _characterPage = 0;
    _hasMoreCharacters = true;
    _characters = const [];
    _charactersStatus = HomeLoadStatus.loading;
    _charactersErrorMessage = null;
    _moreCharactersError = null;
    notifyListeners();

    await _loadCharactersPage();
  }

  Future<void> _loadCharactersPage() async {
    try {
      final page = await _characterRepository.getCharacters(
        page: _characterPage + 1,
      );
      final ordered = [..._characters, ...page.characters]..sort(
        (left, right) =>
            left.name.toLowerCase().compareTo(right.name.toLowerCase()),
      );

      _characterPage = page.page;
      _hasMoreCharacters = page.hasNextPage;
      _characters = List.unmodifiable(ordered);
      _charactersStatus =
          _characters.isEmpty ? HomeLoadStatus.empty : HomeLoadStatus.success;
    } on Exception catch (error) {
      if (_characters.isEmpty) {
        _charactersErrorMessage = error.toString();
        _charactersStatus = HomeLoadStatus.failure;
      } else {
        _moreCharactersError = 'Não foi possível carregar mais personagens.';
      }
    }

    notifyListeners();
  }

  Future<void> loadMoreCharacters() async {
    if (!_hasMoreCharacters ||
        _isLoadingMoreCharacters ||
        _moreCharactersError != null) {
      return;
    }
    _isLoadingMoreCharacters = true;
    notifyListeners();
    await _loadCharactersPage();
    _isLoadingMoreCharacters = false;
    notifyListeners();
  }

  Future<void> retryMoreCharacters() async {
    _moreCharactersError = null;
    await loadMoreCharacters();
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
