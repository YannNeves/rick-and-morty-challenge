import '../../core/network/api_client.dart';

abstract interface class AnalyticsTracker {
  Future<void> track(String name, {Map<String, Object?> properties = const {}});
}

class ApiAnalyticsTracker implements AnalyticsTracker {
  const ApiAnalyticsTracker(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<void> track(
    String name, {
    Map<String, Object?> properties = const {},
  }) async {
    try {
      await _apiClient.postMap(
        '/analytics/events',
        body: {
          'name': name,
          if (properties.isNotEmpty) 'properties': properties,
        },
      );
    } catch (_) {
      // Analytics must never block the main user flow.
    }
  }
}

class NoopAnalyticsTracker implements AnalyticsTracker {
  const NoopAnalyticsTracker();

  @override
  Future<void> track(
    String name, {
    Map<String, Object?> properties = const {},
  }) async {}
}
