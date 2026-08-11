import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../models/video_create_request.dart';

class VideoService {
  VideoService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<String> uploadVideo({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final response = await _apiClient.uploadMultipartFile(
      path: '/api/Video/upload-video',
      fieldName: 'formFile',
      fileName: fileName,
      bytes: bytes,
    );

    final videoUrl = response['videoUrl'];

    if (videoUrl is! String || videoUrl.isEmpty) {
      throw const ApiException(
        statusCode: 500,
        message: 'Server did not return video URL',
      );
    }

    return videoUrl;
  }

  Future<String> uploadThumbnail({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final response = await _apiClient.uploadMultipartFile(
      path: '/api/Video/upload-thumbnail',
      fieldName: 'formFile',
      fileName: fileName,
      bytes: bytes,
    );

    final thumbnailUrl = response['thumbnailUrl'];

    if (thumbnailUrl is! String || thumbnailUrl.isEmpty) {
      throw const ApiException(
        statusCode: 500,
        message: 'Server did not return thumbnail URL',
      );
    }

    return thumbnailUrl;
  }

  Future<String> createVideo(VideoCreateRequest request) async {
    final response = await _apiClient.postJson(
      '/api/Video/create',
      request.toJson(),
    );

    final value = response['value'];

    if (value == null || value.toString().isEmpty) {
      throw const ApiException(
        statusCode: 500,
        message: 'Server did not return the created video ID.',
      );
    }

    return value.toString();
  }
}