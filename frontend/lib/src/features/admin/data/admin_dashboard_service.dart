import 'dart:io';
import 'dart:typed_data';

import '../../../core/network/api_client.dart';
import '../models/dashboard_overview.dart';

class AdminDashboardService {
  AdminDashboardService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<DashboardOverview> getOverview() async {
    final response = await _apiClient.getJson(
      '/api/Report/dashboard',
    );

    if (response is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected dashboard response.',
      );
    }

    return DashboardOverview.fromJson(
      response,
    );
  }

  Future<Uint8List> getRevenueReport({
    DateTime? from,
  }) {
    return _apiClient.getBytes(
      '/api/Report/revenue-report',
      queryParameters: {
        'From': from?.toUtc().toIso8601String(),
      },
    );
  }

  Future<Uint8List> getVideoAnalyticsReport({
    DateTime? from,
  }) {
    return _apiClient.getBytes(
      '/api/Report/video-analytics-report',
      queryParameters: {
        'From': from?.toUtc().toIso8601String(),
      },
    );
  }

  Future<File> saveReport({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final userProfile =
        Platform.environment['USERPROFILE'];

    if (userProfile == null) {
      throw Exception(
        'Unable to locate the user profile directory.',
      );
    }

    final downloadsDirectory = Directory(
      '$userProfile${Platform.pathSeparator}Downloads',
    );

    if (!await downloadsDirectory.exists()) {
      await downloadsDirectory.create(
        recursive: true,
      );
    }

    final file = File(
      '${downloadsDirectory.path}'
      '${Platform.pathSeparator}'
      '$fileName',
    );

    await file.writeAsBytes(
      bytes,
      flush: true,
    );

    return file;
  }
}