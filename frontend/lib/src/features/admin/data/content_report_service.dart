import '../../../core/network/api_client.dart';
import '../../../shared/models/paged_result.dart';
import '../models/content_report_detail.dart';
import '../models/content_report_history_item.dart';
import '../models/content_report_stats.dart';
import '../models/content_report_summary.dart';

class ContentReportService {
  ContentReportService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<PagedResult<ContentReportSummary>>
      getReports({
    int? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.getJson(
      '/api/ContentReport/getall',
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
            'Unexpected content reports response.',
      );
    }

    return PagedResult<ContentReportSummary>
        .fromJson(
      response,
      ContentReportSummary.fromJson,
    );
  }

  Future<ContentReportDetail> getDetail({
    required String contentId,
    required String contentType,
  }) async {
    final response = await _apiClient.getJson(
      '/api/ContentReport/'
      '${contentType.toLowerCase()}/'
      '$contentId',
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message:
            'Unexpected content report detail response.',
      );
    }

    return ContentReportDetail.fromJson(
      response,
    );
  }

  Future<ContentReportStats> getStats() async {
    final response = await _apiClient.getJson(
      '/api/ContentReport/stats',
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message:
            'Unexpected report stats response.',
      );
    }

    return ContentReportStats.fromJson(
      response,
    );
  }

  Future<void> review({
    required String contentId,
    required String contentType,
    required String resolutionNote,
    required int status,
  }) async {
    await _apiClient.patchJson(
      '/api/ContentReport/review-report',
      {
        'contentId': contentId,
        'contentType': contentType,
        'resolutionNote': resolutionNote,
        'status': status,
      },
    );
  }

  Future<void> removeContent({
    required String contentId,
    required String contentType,
  }) async {
    await _apiClient.patchJson(
      '/api/ContentReport/remove-content',
      {
        'contentId': contentId,
        'contentType': contentType,
      },
    );
  }

  Future<PagedResult<ContentReportHistoryItem>> getByStatus({
    required int status,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response = await _apiClient.getJson(
      '/api/ContentReport/by-status',
      queryParameters: {
        'Status': status,
        'Page': page,
        'PageSize': pageSize,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected reports response.',
      );
    }

    return PagedResult<ContentReportHistoryItem>.fromJson(
      response,
      ContentReportHistoryItem.fromJson,
    );
  }
}