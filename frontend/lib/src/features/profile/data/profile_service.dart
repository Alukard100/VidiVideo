import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../models/follow_user.dart';
import '../models/user_profile.dart';

class ProfileService {
  // ignore: prefer_initializing_formals
  ProfileService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<UserProfile> getMyProfile() async {
    final response = await _apiClient.getJson('/api/User/me');

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected profile response.',
      );
    }

    return UserProfile.fromJson(response);
  }

  Future<UserProfile> getProfile(String userId) async {
    final response = await _apiClient.getJson('/api/User/$userId/profile');

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected profile response.',
      );
    }

    return UserProfile.fromJson(response);
  }

  Future<void> updateMyProfile({
    required String displayName,
    required String? bio,
    required String? countryId,
  }) async {
    await _apiClient.patchJson(
      '/api/User/me',
      {
        'displayName': displayName,
        'bio': bio,
        'countryId': countryId,
      },
    );
  }

  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final response = await _apiClient.uploadMultipartFile(
      path: '/api/User/avatar',
      fieldName: 'formFile',
      fileName: fileName,
      bytes: bytes,
    );

    final avatarUrl = response['avatarUrl'];

    if (avatarUrl is! String || avatarUrl.isEmpty) {
      throw const ApiException(
        statusCode: 500,
        message: 'Server did not return avatar URL.',
      );
    }

    return avatarUrl;
  }

  Future<void> follow(String userId) async {
    await _apiClient.postJson(
      '/api/Follow/follow',
      {
        'targetUserId': userId,
      },
    );
  }

  Future<void> unfollow(String userId) async {
    await _apiClient.deleteJson(
      '/api/Follow/unfollow',
      {
        'targetUserId': userId,
      },
    );
  }

  Future<List<FollowUser>> getFollowers({
    required String currentUserId,
    required String targetUserId,
    int page = 1,
    int pageSize = 50,
  }) {
    return _getFollowList(
      path: '/api/Follow/followers',
      currentUserId: currentUserId,
      targetUserId: targetUserId,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<List<FollowUser>> getFollowing({
    required String currentUserId,
    required String targetUserId,
    int page = 1,
    int pageSize = 50,
  }) {
    return _getFollowList(
      path: '/api/Follow/following',
      currentUserId: currentUserId,
      targetUserId: targetUserId,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<List<FollowUser>> _getFollowList({
    required String path,
    required String currentUserId,
    required String targetUserId,
    required int page,
    required int pageSize,
  }) async {
    final response = await _apiClient.getJson(
      path,
      queryParameters: {
        'CurrentUserId': currentUserId,
        'TargetUserId': targetUserId,
        'Page': page,
        'PageSize': pageSize,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected follow list response.',
      );
    }

    final items = response['items'];

    if (items is! List) {
      return const [];
    }

    return items
        .map((item) => FollowUser.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _apiClient.postJson(
      '/api/auth/change-password',
      {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }
}
