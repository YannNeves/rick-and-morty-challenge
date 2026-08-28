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

  Future<void> loadAll() async {
    status = CharactersLoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final allCharacters = <CharacterSummary>[
        ...await _characterRepository.getAllCharacters(),
      ];

      allCharacters.sort(
        (first, second) =>
            first.name.toLowerCase().compareTo(second.name.toLowerCase()),
      );
      characters = List.unmodifiable(allCharacters);
      status = CharactersLoadStatus.success;
      notifyListeners();
    } catch (_) {
      status = CharactersLoadStatus.failure;
      errorMessage = 'Não foi possível carregar os personagens.';
      notifyListeners();
    }
  }
}
