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
  int _page = 0;
  bool _hasNextPage = true;
  bool _isLoadingMore = false;
  String _name = '';
  Map<String, String> _filters = const {};

  bool get isLoadingMore => _isLoadingMore;
  bool get hasNextPage => _hasNextPage;

  Future<void> load({
    String name = '',
    Map<String, String> filters = const {},
  }) async {
    _name = name;
    _filters = Map.unmodifiable(filters);
    _page = 0;
    _hasNextPage = true;
    characters = const [];
    status = CharactersLoadStatus.loading;
    errorMessage = null;
    notifyListeners();
    await _loadNextPage();
  }

  Future<void> loadMore() async {
    if (!_hasNextPage ||
        _isLoadingMore ||
        status == CharactersLoadStatus.loading) {
      return;
    }
    _isLoadingMore = true;
    notifyListeners();
    await _loadNextPage();
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> _loadNextPage() async {
    try {
      final nextPage = _page + 1;
      final result = await _characterRepository.getCharacters(
        page: nextPage,
        name: _name,
        status: _filters['status'],
        gender: _filters['gender'],
      );
      _page = result.page;
      _hasNextPage = result.hasNextPage;
      final updated = <CharacterSummary>[...characters, ...result.characters];
      _sort(updated);
      characters = List.unmodifiable(updated);
      status = CharactersLoadStatus.success;
      notifyListeners();
    } catch (_) {
      status = CharactersLoadStatus.failure;
      errorMessage = 'Não foi possível carregar os personagens.';
      notifyListeners();
    }
  }

  void _sort(List<CharacterSummary> items) {
    final sortBy = _filters['sortBy'] ?? 'name';
    final direction = _filters['order'] == 'desc' ? -1 : 1;
    items.sort((left, right) {
      final result = switch (sortBy) {
        'status' => left.status.compareTo(right.status),
        'species' => left.species.compareTo(right.species),
        _ => left.name.compareTo(right.name),
      };
      return result * direction;
    });
  }
}
