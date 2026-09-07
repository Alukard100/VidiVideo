import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../../core/utils/file_name_utils.dart';
import '../../../shared/models/paged_result.dart';
import '../models/channel_emoji.dart';

class EmojiService {
  EmojiService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<PagedResult<ChannelEmoji>> getMine({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.getJson(
      '/api/Emoji/mine',
      queryParameters: {
        'Page': page,
        'PageSize': pageSize,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected emoji response.',
      );
    }

    return PagedResult<ChannelEmoji>.fromJson(
      response,
      ChannelEmoji.fromJson,
    );
  }

  Future<PagedResult<ChannelEmoji>> getAvailable({
    int page = 1,
    int pageSize = 16,
  }) async {
    final response = await _apiClient.getJson(
      '/api/Emoji/available',
      queryParameters: {
        'Page': page,
        'PageSize': pageSize,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected emoji response.',
      );
    }

    return PagedResult<ChannelEmoji>.fromJson(
      response,
      ChannelEmoji.fromJson,
    );
  }

  Future<String> uploadEmoji({
    required String code,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final response = await _apiClient.postMultipart(
      path: '/api/Emoji/upload-emoji',
      fields: {
        'code': code,
      },
      files: [
        MultipartFileData(
          fieldName: 'formFile',
          fileName: safeUploadFileName(fileName),
          bytes: bytes,
          contentType: 'application/octet-stream',
        ),
      ],
    );

    final value = response['value'];

    if (value == null || value.toString().isEmpty) {
      throw const ApiException(
        statusCode: 500,
        message: 'Server did not return emoji ID.',
      );
    }

    return value.toString();
  }

  Future<void> deleteEmoji(
    String emojiId,
  ) async {
    await _apiClient.deleteJson(
      '/api/Emoji/$emojiId',
      const {},
    );
  }
}