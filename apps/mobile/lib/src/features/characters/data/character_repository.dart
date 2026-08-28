import '../../../core/network/api_client.dart';
import '../domain/character_models.dart';

abstract interface class CharacterRepository {
  Future<CharacterListPage> getCharacters({int page = 1});
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
}
