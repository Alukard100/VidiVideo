import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../config/app_config.dart';
import '../storage/session_store.dart';

typedef UnauthorizedCallback = Future<void> Function(
  ApiException exception,
  int requestSessionRevision,
);

class ApiClient {
  ApiClient({
    required SessionStore sessionStore,
    UnauthorizedCallback? onUnauthorized,
  }) : _sessionStore = sessionStore,
       _onUnauthorized = onUnauthorized;

  final SessionStore _sessionStore;
  final UnauthorizedCallback? _onUnauthorized;

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final baseUrl = AppConfig.apiBaseUrl;

    final uri = Uri.parse('$baseUrl$path');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    final queryItems = <String>[];

    for (final entry in queryParameters.entries) {
      final value = entry.value;

      if (value == null) {
        continue;
      }

      if (value is Iterable) {
        for (final item in value) {
          queryItems.add(
            '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(item.toString())}',
          );
        }
      } else {
        queryItems.add(
          '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(value.toString())}',
        );
      }
    }

    return uri.replace(query: queryItems.join('&'));
  }

  int? _addDefaultHeaders(HttpHeaders headers) {
    headers.contentType = ContentType.json;
    headers.set(HttpHeaders.acceptHeader, ContentType.json.toString());

    return _addAuthorizationHeader(headers);
  }

  int? _addAuthorizationHeader(HttpHeaders headers) {
    final sessionRevision = _sessionStore.revision;

    final token = _sessionStore.accessToken;

    if (token != null && token.isNotEmpty) {
      headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $token',
      );
      return sessionRevision;
    }

    return null;
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final client = HttpClient();

    try {
      final request = await client.postUrl(_buildUri(path));

      final sessionRevision = _addDefaultHeaders(request.headers);

      request.write(jsonEncode(body));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      await _throwIfError(
        statusCode: response.statusCode,
        responseBody: responseBody,
        requestSessionRevision: sessionRevision,
      );

      if (responseBody.trim().isEmpty) {
        return <String, dynamic>{};
      }

      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return <String, dynamic>{
        'value': decoded,
      };
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> patchJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final client = HttpClient();

    try {
      final request = await client.patchUrl(_buildUri(path));

      final sessionRevision = _addDefaultHeaders(request.headers);

      request.write(jsonEncode(body));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      await _throwIfError(
        statusCode: response.statusCode,
        responseBody: responseBody,
        requestSessionRevision: sessionRevision,
      );

      if (responseBody.trim().isEmpty) {
        return <String, dynamic>{};
      }

      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return <String, dynamic>{
        'value': decoded,
      };
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> deleteJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final client = HttpClient();

    try {
      final request = await client.deleteUrl(_buildUri(path));

      final sessionRevision = _addDefaultHeaders(request.headers);

      request.write(jsonEncode(body));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      await _throwIfError(
        statusCode: response.statusCode,
        responseBody: responseBody,
        requestSessionRevision: sessionRevision,
      );

      if (responseBody.trim().isEmpty) {
        return <String, dynamic>{};
      }

      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

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

      final sessionRevision = _addDefaultHeaders(request.headers);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      await _throwIfError(
        statusCode: response.statusCode,
        responseBody: responseBody,
        requestSessionRevision: sessionRevision,
      );

      if (responseBody.trim().isEmpty) {
        return null;
      }

      return jsonDecode(responseBody);
    } finally {
      client.close(force: true);
    }
  }

  Future<Uint8List> getBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final client = HttpClient();

    try {
      final request = await client.getUrl(
        _buildUri(path, queryParameters),
      );

      final sessionRevision = _addAuthorizationHeader(request.headers);

      final response = await request.close();

      final bytes = await response.fold<List<int>>(
        <int>[],
        (previous, element) =>
            previous..addAll(element),
      );

      await _throwIfError(
        statusCode: response.statusCode,
        responseBody: utf8.decode(bytes),
        requestSessionRevision: sessionRevision,
      );

      return Uint8List.fromList(bytes);
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

      final sessionRevision = _addAuthorizationHeader(request.headers);

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

      await _throwIfError(
        statusCode: response.statusCode,
        responseBody: responseBody,
        requestSessionRevision: sessionRevision,
      );

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

  Future<Map<String, dynamic>> postMultipart({
    required String path,
    required Map<String, String> fields,
    required List<MultipartFileData> files,
  }) async {
    final client = HttpClient();

    try {
      final request = await client.postUrl(_buildUri(path));

      final sessionRevision = _addAuthorizationHeader(request.headers);

      final boundary =
          '----VidiVideoBoundary${DateTime.now().microsecondsSinceEpoch}';

      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );

      for (final entry in fields.entries) {
        request.write('--$boundary\r\n');
        request.write(
          'Content-Disposition: form-data; name="${entry.key}"\r\n\r\n',
        );
        request.write(entry.value);
        request.write('\r\n');
      }

      for (final file in files) {
        request.write('--$boundary\r\n');
        request.write(
          'Content-Disposition: form-data; '
          'name="${file.fieldName}"; '
          'filename="${file.fileName}"\r\n',
        );
        request.write(
          'Content-Type: ${file.contentType}\r\n\r\n',
        );

        request.add(file.bytes);

        request.write('\r\n');
      }

      request.write('--$boundary--\r\n');

      final response = await request.close();

      final responseBody = await response.transform(utf8.decoder).join();

      await _throwIfError(
        statusCode: response.statusCode,
        responseBody: responseBody,
        requestSessionRevision: sessionRevision,
      );

      if (responseBody.trim().isEmpty) {
        return <String, dynamic>{};
      }

      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return <String, dynamic>{
        'value': decoded,
      };
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _throwIfError({
    required int statusCode,
    required String responseBody,
    required int? requestSessionRevision,
  }) async {
    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    final exception = ApiException(
      statusCode: statusCode,
      message: _extractErrorMessage(responseBody),
      isAuthenticatedUnauthorized:
          statusCode == HttpStatus.unauthorized &&
          requestSessionRevision != null,
    );

    if (statusCode == HttpStatus.unauthorized &&
        requestSessionRevision != null) {
      await _onUnauthorized?.call(exception, requestSessionRevision);
    }

    throw exception;
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

class MultipartFileData {
  const MultipartFileData({
    required this.fieldName,
    required this.fileName,
    required this.bytes,
    this.contentType = 'application/octet-stream',
  });

  final String fieldName;
  final String fileName;
  final Uint8List bytes;
  final String contentType;
}

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.isAuthenticatedUnauthorized = false,
  });

  final int statusCode;
  final String message;
  final bool isAuthenticatedUnauthorized;

  @override
  String toString() {
    return 'ApiException($statusCode): $message';
  }
}
