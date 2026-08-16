import 'dart:typed_data';

import '../../../core/network/api_client.dart';
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
}
