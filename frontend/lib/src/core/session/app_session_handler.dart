import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../network/api_client.dart';
import '../notifications/app_notification_service.dart';
import '../storage/session_store.dart';

class AppSessionHandler {
  AppSessionHandler({
    required SessionStore sessionStore,
    required AppNotificationService notificationService,
    required GlobalKey<NavigatorState> navigatorKey,
  }) : _sessionStore = sessionStore,
       _notificationService = notificationService,
       _navigatorKey = navigatorKey;

  final SessionStore _sessionStore;
  final AppNotificationService _notificationService;
  final GlobalKey<NavigatorState> _navigatorKey;

  int? _handledSessionRevision;

  Future<void> handleUnauthorized(
    ApiException exception,
    int requestSessionRevision,
  ) async {
    if (_handledSessionRevision == requestSessionRevision ||
        !_sessionStore.isAuthenticated ||
        _sessionStore.revision != requestSessionRevision) {
      return;
    }

    _handledSessionRevision = requestSessionRevision;
    _sessionStore.clearSession();

    _notificationService.showError(
      title: 'Session expired',
      message: exception.message,
      statusCode: exception.statusCode,
    );

    final navigator = _navigatorKey.currentState;

    if (navigator != null) {
      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (_) => false,
      );
    });
  }
}
