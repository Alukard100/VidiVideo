import '../../../core/network/api_client.dart';
import '../../../shared/models/paged_result.dart';
import '../models/admin_staff_member.dart';

class AdminStaffService {
  AdminStaffService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<PagedResult<AdminStaffMember>> getStaff({
    String? search,
    String? role,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _apiClient.getJson(
      '/api/User/staff',
      queryParameters: {
        'Page': page,
        'PageSize': pageSize,
        if (search != null && search.trim().isNotEmpty)
          'Search': search.trim(),
        if (role != null && role.trim().isNotEmpty) 'Role': role.trim(),
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected staff response.',
      );
    }

    return PagedResult<AdminStaffMember>.fromJson(
      response,
      AdminStaffMember.fromJson,
    );
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
