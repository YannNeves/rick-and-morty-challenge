import '../../../core/network/api_client.dart';
import '../domain/character_models.dart';

abstract interface class CharacterRepository {
  Future<CharacterListPage> getCharacters({
    int page = 1,
    String? name,
    String? status,
    String? species,
  });
  Future<CharacterDetails> getCharacterDetails(int id);
}

class RemoteCharacterRepository implements CharacterRepository {
  const RemoteCharacterRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<CharacterListPage> getCharacters({
    int page = 1,
    String? name,
    String? status,
    String? species,
  }) async {
    final query = <String, String>{'page': '$page'};
    if (name?.isNotEmpty ?? false) query['name'] = name!;
    if (status?.isNotEmpty ?? false) query['status'] = status!;
    if (species?.isNotEmpty ?? false) query['species'] = species!;
    final json = await _apiClient.getMap('/characters', query: query);
    return CharacterListPage.fromJson(json);
  }

  @override
  Future<CharacterDetails> getCharacterDetails(int id) async {
    return CharacterDetails.fromJson(
      await _apiClient.getMap('/characters/$id'),
    );
  }
}
