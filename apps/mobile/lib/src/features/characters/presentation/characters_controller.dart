import 'package:flutter/foundation.dart';

import '../data/character_repository.dart';
import '../domain/character_models.dart';

enum CharactersLoadStatus { idle, loading, success, failure }

class CharactersController extends ChangeNotifier {
  CharactersController({required CharacterRepository characterRepository})
    : _characterRepository = characterRepository;

  static const _concurrentRequests = 5;

  final CharacterRepository _characterRepository;

  CharactersLoadStatus status = CharactersLoadStatus.idle;
  List<CharacterSummary> characters = const [];
  String? errorMessage;

  Future<void> loadAll() async {
    status = CharactersLoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final firstPage = await _characterRepository.getCharacters();
      final allCharacters = <CharacterSummary>[...firstPage.characters];

      for (
        var firstPageNumber = 2;
        firstPageNumber <= firstPage.totalPages;
        firstPageNumber += _concurrentRequests
      ) {
        final lastPageNumber = (firstPageNumber + _concurrentRequests - 1)
            .clamp(firstPageNumber, firstPage.totalPages);
        final pages = await Future.wait([
          for (
            var pageNumber = firstPageNumber;
            pageNumber <= lastPageNumber;
            pageNumber++
          )
            _characterRepository.getCharacters(page: pageNumber),
        ]);
        for (final page in pages) {
          allCharacters.addAll(page.characters);
        }
      }

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
