import '../../../core/network/api_client.dart';
import '../domain/location_models.dart';

abstract interface class LocationRepository {
  Future<LocationListPage> getLocations({int page = 1});
  Future<List<LocationSummary>> getAllLocations();
  Future<List<LocationSummary>> getLocationsBatch(List<int> ids);
  Future<LocationDetails> getLocationDetails(int id);
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

  @override
  Future<List<LocationSummary>> getAllLocations() async {
    final json = await _apiClient.getMap('/locations/all');
    final items = json['locations'] as List<dynamic>? ?? const [];
    return items
        .map(
          (item) =>
              LocationSummary.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
  }

  @override
  Future<List<LocationSummary>> getLocationsBatch(List<int> ids) async {
    if (ids.isEmpty) return const [];
    final json = await _apiClient.getMap(
      '/locations/batch',
      query: {'ids': ids.join(',')},
    );
    final items = json['locations'] as List<dynamic>? ?? const [];
    return items
        .map(
          (item) =>
              LocationSummary.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false);
  }

  @override
  Future<LocationDetails> getLocationDetails(int id) async {
    final json = await _apiClient.getMap('/locations/$id');
    return LocationDetails.fromJson(json);
  }
}
