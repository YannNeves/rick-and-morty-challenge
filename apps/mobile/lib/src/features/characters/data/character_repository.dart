import '../../../core/network/api_client.dart';
import '../domain/character_models.dart';

abstract interface class CharacterRepository {
  Future<CharacterListPage> getCharacters({int page = 1});
  Future<List<CharacterSummary>> getAllCharacters();
  Future<CharacterDetails> getCharacterDetails(int id);
}

class RemoteCharacterRepository implements CharacterRepository {
  const RemoteCharacterRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<CharacterListPage> getCharacters({int page = 1}) async {
    final json = await _apiClient.getMap(
      '/characters',
      query: {'page': '$page'},
    );
    return CharacterListPage.fromJson(json);
  }

  @override
  Future<List<CharacterSummary>> getAllCharacters() async {
    final json = await _apiClient.getMap('/characters/all');
    final items = json['characters'] as List<dynamic>? ?? const [];
    return items
        .map(
          (item) =>
              CharacterSummary.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
  }

  @override
  Future<CharacterDetails> getCharacterDetails(int id) async {
    return CharacterDetails.fromJson(
      await _apiClient.getMap('/characters/$id'),
    );
  }
}
