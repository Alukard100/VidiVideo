import '../../../core/network/api_client.dart';
import '../../../shared/models/paged_result.dart';
import '../models/admin_user_summary.dart';

class AdminUserService {
  AdminUserService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<PagedResult<AdminUserSummary>> getUsers({
    String? search,
    int? status,
    String sortBy = 'RegistrationDate',
    String sortWay = 'Descending',
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.getJson(
      '/api/User/admin',
      queryParameters: {
        'Search': search,
        'Status': status,
        'SortBy': sortBy,
        'SortWay': sortWay,
        'Page': page,
        'PageSize': pageSize,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected users response.',
      );
    }


    return PagedResult<AdminUserSummary>.fromJson(
      response,
      AdminUserSummary.fromJson,
    );
  }

  Future<void> updateStatus({
    required String userId,
    required int status,
  }) async {
    await _apiClient.patchJson(
      '/api/User/$userId/status',
      {
        'status': status,
      },
    );
  }

}