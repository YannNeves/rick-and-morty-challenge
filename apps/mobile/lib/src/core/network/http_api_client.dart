import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/app_exception.dart';
import 'api_client.dart';

class HttpApiClient implements ApiClient {
  HttpApiClient({
    required this.baseUri,
    required http.Client httpClient,
    this.timeout = const Duration(seconds: 8),
  }) : _httpClient = httpClient;

  final Uri baseUri;
  final Duration timeout;
  final http.Client _httpClient;

  @override
  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _httpClient
        .get(
          _resolve(path, query),
          headers: const {'accept': 'application/json'},
        )
        .timeout(timeout);

    return _decodeMap(response);
  }

  @override
  Future<void> postMap(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _httpClient
        .post(
          _resolve(path),
          headers: const {
            'accept': 'application/json',
            'content-type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionFromResponse(response);
    }
  }

  Uri _resolve(String path, [Map<String, String>? query]) {
    final basePath =
        baseUri.path.endsWith('/')
            ? baseUri.path.substring(0, baseUri.path.length - 1)
            : baseUri.path;
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    final queryParameters = query == null || query.isEmpty ? null : query;

    return baseUri.replace(
      path: '$basePath/$normalizedPath',
      queryParameters: queryParameters,
    );
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _exceptionFromResponse(response);
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    throw const AppException('Resposta inesperada da API.');
  }

  AppException _exceptionFromResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['error'] is Map) {
        final error = Map<String, dynamic>.from(decoded['error'] as Map);

        return AppException(
          error['message']?.toString() ?? 'Erro ao consultar a API.',
          code: error['code']?.toString(),
          statusCode: response.statusCode,
        );
      }
    } on FormatException {
      // Keeps the fallback message below for non-json errors.
    }

    return AppException(
      'Erro ao consultar a API.',
      statusCode: response.statusCode,
    );
  }
}
