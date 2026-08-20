import '../../../core/network/api_client.dart';
import '../models/notification_item.dart';

class NotificationService {
  NotificationService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<NotificationItem>> getNotifications({
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _apiClient.getJson(
      '/api/Notification/mynotifications',
      queryParameters: {
        'Page': page,
        'PageSize': pageSize,
      },
    );

    if (response is! Map<String, dynamic>) {
      return const [];
    }

    final items = response['items'];

    if (items is! List) {
      return const [];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(NotificationItem.fromJson)
        .toList();
  }

  Future<void> markAsRead(
    String notificationId,
  ) async {
    await _apiClient.patchJson(
      '/api/Notification/read',
      {
        'notificationId': notificationId,
      },
    );
  }

  Future<void> markAllAsRead() async {
    await _apiClient.patchJson(
      '/api/Notification/read-all',
      {},
    );
  }
}