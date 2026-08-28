import '../../../core/network/api_client.dart';
import '../domain/location_models.dart';

abstract interface class LocationRepository {
  Future<LocationListPage> getLocations({int page = 1});
}

class RemoteLocationRepository implements LocationRepository {
  const RemoteLocationRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<LocationListPage> getLocations({int page = 1}) async {
    final json = await _apiClient.getMap(
      '/locations',
      query: {'page': '$page'},
    );
    return LocationListPage.fromJson(json);
  }
}
