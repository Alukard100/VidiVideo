import 'dart:convert';
import 'dart:io';

import '../config/app_config.dart';

class ApiClient {
  ApiClient({HttpClient? httpClient}) : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  Future<Map<String, dynamic>> getJson(String path) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final request = await _httpClient.getUrl(uri);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, body);
    }

    if (body.isEmpty) {
      return {};
    }

    return jsonDecode(body) as Map<String, dynamic>;
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, body: $body)';
}
