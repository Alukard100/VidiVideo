import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../config/app_config.dart';
import '../storage/session_store.dart';

class ApiClient {
  ApiClient({
    required SessionStore sessionStore,
  }) : _sessionStore = sessionStore;

  final SessionStore _sessionStore;

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final baseUrl = AppConfig.apiBaseUrl;

    final uri = Uri.parse('$baseUrl$path');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  void _addDefaultHeaders(HttpHeaders headers) {
    headers.contentType = ContentType.json;
    headers.set(HttpHeaders.acceptHeader, ContentType.json.toString());

    final token = _sessionStore.accessToken;

    if (token != null && token.isNotEmpty) {
      headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $token',
      );
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final client = HttpClient();

    try {
      final request = await client.postUrl(_buildUri(path));

      _addDefaultHeaders(request.headers);

      request.write(jsonEncode(body));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(responseBody),
        );
      }

      if (responseBody.trim().isEmpty) {
        return <String, dynamic>{};
      }

      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      // Endpoint /create vraća samo Guid string, a ne JSON objekat.
      return <String, dynamic>{
        'value': decoded,
      };
    } finally {
      client.close(force: true);
    }
  }

  Future<dynamic> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final client = HttpClient();

    try {
      final request = await client.getUrl(
        _buildUri(path, queryParameters),
      );

      _addDefaultHeaders(request.headers);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(responseBody),
        );
      }

      if (responseBody.trim().isEmpty) {
        return null;
      }

      return jsonDecode(responseBody);
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> uploadMultipartFile({
    required String path,
    required String fieldName,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final client = HttpClient();

    try {
      final request = await client.postUrl(_buildUri(path));

      final token = _sessionStore.accessToken;

      if (token != null && token.isNotEmpty) {
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Bearer $token',
        );
      }

      final boundary =
          '----VidiVideoBoundary${DateTime.now().microsecondsSinceEpoch}';

      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );

      request.write('--$boundary\r\n');
      request.write(
        'Content-Disposition: form-data; '
        'name="$fieldName"; '
        'filename="$fileName"\r\n',
      );
      request.write('Content-Type: application/octet-stream\r\n\r\n');

      request.add(bytes);

      request.write('\r\n--$boundary--\r\n');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          statusCode: response.statusCode,
          message: _extractErrorMessage(responseBody),
        );
      }

      if (responseBody.trim().isEmpty) {
        throw const ApiException(
          statusCode: 500,
          message: 'Server did not return the uploaded file URL.',
        );
      }

      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected upload response.',
      );
    } finally {
      client.close(force: true);
    }
  }

  String _extractErrorMessage(String responseBody) {
    if (responseBody.trim().isEmpty) {
      return 'Request failed.';
    }

    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        return decoded['detail']?.toString() ??
            decoded['title']?.toString() ??
            decoded['message']?.toString() ??
            'Request failed.';
      }

      return decoded.toString();
    } catch (_) {
      return responseBody;
    }
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() {
    return 'ApiException($statusCode): $message';
  }
}