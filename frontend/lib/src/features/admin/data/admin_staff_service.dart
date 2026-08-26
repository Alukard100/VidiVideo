import '../../../core/network/api_client.dart';
import '../models/admin_staff_member.dart';

class AdminStaffService {
  AdminStaffService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<AdminStaffMember>> getStaff() async {
    final response = await _apiClient.getJson(
      '/api/User/staff',
      queryParameters: {
        'Page': '1',
        'PageSize': '10',
      },
    );

    final items = response['items'];

    if (items is! List) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected staff response.',
      );
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(AdminStaffMember.fromJson)
        .toList();
  }

  Future<void> createStaff({
    required String userName,
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    await _apiClient.postJson(
      '/api/User/staff',
      {
        'userName': userName,
        'email': email,
        'password': password,
        'displayName': displayName,
        'role': role,
      },
    );
  }

  Future<void> updateRole({
    required String targetId,
    required String role,
  }) async {
    await _apiClient.patchJson(
      '/api/User/staff/update',
      {
        'targetId': targetId,
        'role': role,
      },
    );
  }

  Future<void> removeStaff(
    String targetId,
  ) async {
    await _apiClient.deleteJson(
      '/api/User/staff/$targetId',
      {},
    );
  }
}