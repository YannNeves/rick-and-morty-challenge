import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  final String apiBaseUrl;

  factory AppConfig.fromEnvironment() {
    const configuredApiUrl = String.fromEnvironment('API_BASE_URL');

    return AppConfig(
      apiBaseUrl:
          configuredApiUrl.isNotEmpty ? configuredApiUrl : _defaultApiBaseUrl(),
    );
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
