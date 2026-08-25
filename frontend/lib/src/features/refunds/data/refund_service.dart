import '../../../core/network/api_client.dart';
import '../../../shared/models/paged_result.dart';
import '../models/refund_request.dart';

class RefundService {
  RefundService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<void> requestRefund({
    required String creatorId,
  }) async {
    await _apiClient.postJson(
      '/api/Refund/request',
      {
        'creatorId': creatorId,
      },
    );
  }

  Future<PagedResult<RefundRequestItem>>
      getRefundRequests({
    int? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.getJson(
      '/api/Refund',
      queryParameters: {
        'Status': status,
        'Page': page,
        'PageSize': pageSize,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message:
            'Unexpected refund requests response.',
      );
    }

    return PagedResult<RefundRequestItem>.fromJson(
      response,
      RefundRequestItem.fromJson,
    );
  }

  Future<void> approve({
    required String refundRequestId,
  }) async {
    await _apiClient.patchJson(
      '/api/Refund/$refundRequestId/approve',
      const {},
    );
  }

  Future<void> reject({
    required String refundRequestId,
  }) async {
    await _apiClient.patchJson(
      '/api/Refund/$refundRequestId/reject',
      const {},
    );
  }
}