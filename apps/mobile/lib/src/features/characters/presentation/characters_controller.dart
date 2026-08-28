import 'package:flutter/foundation.dart';

import '../data/character_repository.dart';
import '../domain/character_models.dart';

enum CharactersLoadStatus { idle, loading, success, failure }

class CharactersController extends ChangeNotifier {
  CharactersController({required CharacterRepository characterRepository})
    : _characterRepository = characterRepository;

  final CharacterRepository _characterRepository;

  CharactersLoadStatus status = CharactersLoadStatus.idle;
  List<CharacterSummary> characters = const [];
  String? errorMessage;
  String? loadMoreErrorMessage;
  int _page = 0;
  bool _hasNextPage = true;
  bool _isLoadingMore = false;
  String _name = '';
  Map<String, String> _filters = const {};
  int _generation = 0;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasNextPage => _hasNextPage;

  Future<void> load({
    String name = '',
    Map<String, String> filters = const {},
  }) async {
    final generation = ++_generation;
    _name = name;
    _filters = Map.unmodifiable(filters);
    _page = 0;
    _hasNextPage = true;
    _isLoadingMore = false;
    characters = const [];
    status = CharactersLoadStatus.loading;
    errorMessage = null;
    loadMoreErrorMessage = null;
    notifyListeners();
    await _loadNextPage(generation);
  }

  Future<void> loadMore() async {
    if (!_hasNextPage ||
        _isLoadingMore ||
        loadMoreErrorMessage != null ||
        status == CharactersLoadStatus.loading) {
      return;
    }
    _isLoadingMore = true;
    notifyListeners();
    final generation = _generation;
    await _loadNextPage(generation);
    if (generation != _generation) return;
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> retryLoadMore() async {
    if (_isLoadingMore || !_hasNextPage) return;
    loadMoreErrorMessage = null;
    notifyListeners();
    await loadMore();
  }

  Future<void> _loadNextPage(int generation) async {
    try {
      final nextPage = _page + 1;
      final result = await _characterRepository.getCharacters(
        page: nextPage,
        name: _name,
        status: _filters['status'],
        species: _filters['species'],
      );
      if (generation != _generation) return;
      _page = result.page;
      _hasNextPage = result.hasNextPage;
      final updated = <CharacterSummary>[...characters, ...result.characters];
      _sort(updated);
      characters = List.unmodifiable(updated);
      status = CharactersLoadStatus.success;
      loadMoreErrorMessage = null;
      notifyListeners();
    } catch (_) {
      if (generation != _generation) return;
      if (characters.isEmpty) {
        status = CharactersLoadStatus.failure;
        errorMessage = 'Não foi possível carregar os personagens.';
      } else {
        status = CharactersLoadStatus.success;
        loadMoreErrorMessage =
            'Não foi possível carregar mais personagens agora.';
      }
      notifyListeners();
    }
  }

  void _sort(List<CharacterSummary> items) {
    final sortBy = _filters['sortBy'] ?? 'name';
    final direction = _filters['order'] == 'desc' ? -1 : 1;
    items.sort((left, right) {
      final result = switch (sortBy) {
        'status' => left.status.toLowerCase().compareTo(
          right.status.toLowerCase(),
        ),
        'species' => left.species.toLowerCase().compareTo(
          right.species.toLowerCase(),
        ),
        _ => left.name.toLowerCase().compareTo(right.name.toLowerCase()),
      };
      return (result == 0 ? left.id.compareTo(right.id) : result) * direction;
    });
  }
}
