import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  final String apiBaseUrl;

  factory AppConfig.fromEnvironment() {
    const configuredApiUrl = String.fromEnvironment('API_BASE_URL');
    if (kReleaseMode && configuredApiUrl.isEmpty) {
      throw StateError('API_BASE_URL must be provided for release builds.');
    }

    final apiBaseUrl =
        configuredApiUrl.isNotEmpty ? configuredApiUrl : _defaultApiBaseUrl();
    final uri = Uri.tryParse(apiBaseUrl);
    if (uri == null ||
        !uri.hasScheme ||
        !const {'http', 'https'}.contains(uri.scheme) ||
        uri.host.isEmpty) {
      throw StateError('API_BASE_URL must be a valid HTTP(S) URL.');
    }

    if (kReleaseMode &&
        const {'localhost', '127.0.0.1', '10.0.2.2'}.contains(uri.host)) {
      throw StateError('API_BASE_URL cannot point to localhost in release.');
    }

    return AppConfig(apiBaseUrl: apiBaseUrl);
  }

  static String _defaultApiBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:3000/api/v1',
      _ => 'http://localhost:3000/api/v1',
    };
  }
}
