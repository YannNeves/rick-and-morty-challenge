abstract interface class ApiClient {
  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, String>? query,
  });
}
