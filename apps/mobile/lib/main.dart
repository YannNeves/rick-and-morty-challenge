import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'src/app/app.dart';
import 'src/app/app_config.dart';
import 'src/core/network/http_api_client.dart';
import 'src/features/episodes/data/episode_repository.dart';

void main() {
  final config = AppConfig.fromEnvironment();
  final apiClient = HttpApiClient(
    baseUri: Uri.parse(config.apiBaseUrl),
    httpClient: http.Client(),
  );

  runApp(
    RickAndMortyApp(episodeRepository: RemoteEpisodeRepository(apiClient)),
  );
}
