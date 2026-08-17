import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../../../core/utils/file_name_utils.dart';
import '../models/video_create_request.dart';
import '../models/video_comment.dart';
import '../models/video_detail.dart';
import 'video_summary.dart';

class VideoService {
  // ignore: prefer_initializing_formals
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
      fileName: safeUploadFileName(fileName),
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
      fileName: safeUploadFileName(fileName),
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

  Future<List<VideoSummary>> searchVideos({
    required String? search,
    required String? categoryId,
    required List<String> hashtags,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.getJson(
      '/api/Video/getall',
      queryParameters: {
        'Search': search,
        'CategoryId': categoryId,
        'Hashtags': hashtags,
        'Page': page,
        'PageSize': pageSize,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected search response.',
      );
    }

    final items = response['items'];

    if (items is! List) {
      return const [];
    }

    return items
        .map((item) => VideoSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<VideoDetail>> getRecommendedVideos({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.getJson(
      '/api/Video/recommended',
      queryParameters: {
        'Page': page,
        'PageSize': pageSize,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected recommended videos response.',
      );
    }

    final items = response['items'];

    if (items is! List) {
      return const [];
    }

    return items
        .map((item) => VideoDetail.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<VideoDetail>> getFollowingVideos({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.getJson(
      '/api/Video/following',
      queryParameters: {
        'Page': page,
        'PageSize': pageSize,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected following videos response.',
      );
    }

    final items = response['items'];

    if (items is! List) {
      return const [];
    }

    return items
        .map((item) => VideoDetail.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> recordSearch(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      return;
    }

    await _apiClient.postJson(
      '/api/SearchHistory',
      {
        'query': trimmed,
      },
    );
  }

  Future<void> recordVideoView({
    required String videoId,
    required int watchDurationSeconds,
    required double completionRate,
  }) async {
    await _apiClient.postJson(
      '/api/VideoView/record',
      {
        'videoId': videoId,
        'watchDurationSeconds': watchDurationSeconds,
        'completionRate': completionRate,
      },
    );
  }

  Future<VideoDetail> getVideo(String videoId) async {
    final response = await _apiClient.getJson('/api/Video/$videoId');

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected video response.',
      );
    }

    return VideoDetail.fromJson(response);
  }

  Future<List<VideoComment>> getComments(String videoId) async {
    final response = await _apiClient.getJson(
      '/api/Comment/getComments',
      queryParameters: {
        'videoId': videoId,
        'page': 1,
        'pageSize': 50,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected comments response.',
      );
    }

    final items = response['items'];

    if (items is! List) {
      return const [];
    }

    return items
        .map((item) => VideoComment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> addComment({
    required String videoId,
    required String content,
  }) async {
    await _apiClient.postJson(
      '/api/Comment/create',
      {
        'videoId': videoId,
        'content': content,
      },
    );
  }

  Future<void> likeVideo(String videoId) async {
    await _apiClient.postJson(
      '/api/Like/like',
      {
        'videoId': videoId,
      },
    );
  }

  Future<void> unlikeVideo(String videoId) async {
    await _apiClient.deleteJson(
      '/api/Like/unlike',
      {
        'videoId': videoId,
      },
    );
  }

  Future<void> reportVideo({
    required String videoId,
    required String reason,
  }) async {
    await _apiClient.postJson(
      '/api/ContentReport/report',
      {
        'videoId': videoId,
        'commentId': null,
        'reason': reason,
      },
    );
  }
}
