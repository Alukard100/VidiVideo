import '../network/api_client.dart';
import '../notifications/app_notification_service.dart';

class AppErrorHandler {
  const AppErrorHandler({
    required AppNotificationService notificationService,
  }) : _notificationService = notificationService;

  final AppNotificationService _notificationService;

  void showApiException(
    ApiException exception, {
    String? title,
  }) {
    // Authenticated 401 responses are already presented by the centralized
    // session handler. Avoid a second notification from a local catch block.
    if (exception.isAuthenticatedUnauthorized) {
      return;
    }

    _notificationService.showError(
      title: title ?? _titleForStatus(exception.statusCode),
      message: exception.message,
      statusCode: exception.statusCode,
    );
  }

  String _titleForStatus(int statusCode) {
    return switch (statusCode) {
      400 => 'Invalid request',
      403 => 'Access denied',
      404 => 'Not found',
      409 => 'Conflict',
      >= 500 => 'Server error',
      _ => 'Request failed',
    };
  }
}
