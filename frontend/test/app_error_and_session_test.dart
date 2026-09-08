import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidivideo_app/src/core/error/app_error_handler.dart';
import 'package:vidivideo_app/src/core/network/api_client.dart';
import 'package:vidivideo_app/src/core/notifications/app_notification_service.dart';
import 'package:vidivideo_app/src/core/session/app_session_handler.dart';
import 'package:vidivideo_app/src/core/storage/session_store.dart';

void main() {
  testWidgets('notification remains available while a dialog is open', (
    tester,
  ) async {
    final notificationService = AppNotificationService();
    final navigatorKey = GlobalKey<NavigatorState>();

    await _pumpHarness(
      tester,
      notificationService: notificationService,
      navigatorKey: navigatorKey,
    );

    showDialog<void>(
      context: navigatorKey.currentContext!,
      builder: (_) => const AlertDialog(title: Text('Open dialog')),
    );
    await tester.pumpAndSettle();

    AppErrorHandler(
      notificationService: notificationService,
    ).showApiException(
      const ApiException(statusCode: 403, message: 'Permission required.'),
    );
    await tester.pump();

    expect(find.text('Open dialog'), findsOneWidget);
    expect(find.text('Access denied'), findsOneWidget);
    expect(find.text('Permission required.'), findsOneWidget);
    expect(find.text('HTTP 403'), findsOneWidget);

    notificationService.dismiss();
  });

  testWidgets('authenticated 401 is handled once per session revision', (
    tester,
  ) async {
    final notificationService = AppNotificationService();
    final navigatorKey = GlobalKey<NavigatorState>();
    final sessionStore = SessionStore()
      ..saveSession(accessToken: 'token', role: 'User');
    final requestRevision = sessionStore.revision;
    final handler = AppSessionHandler(
      sessionStore: sessionStore,
      notificationService: notificationService,
      navigatorKey: navigatorKey,
    );

    await _pumpHarness(
      tester,
      notificationService: notificationService,
      navigatorKey: navigatorKey,
    );

    await handler.handleUnauthorized(
      const ApiException(
        statusCode: 401,
        message: 'Token expired.',
        isAuthenticatedUnauthorized: true,
      ),
      requestRevision,
    );
    await handler.handleUnauthorized(
      const ApiException(
        statusCode: 401,
        message: 'Duplicate response.',
        isAuthenticatedUnauthorized: true,
      ),
      requestRevision,
    );
    await tester.pumpAndSettle();

    expect(sessionStore.isAuthenticated, isFalse);
    expect(find.text('Login page'), findsOneWidget);
    expect(find.text('Token expired.'), findsOneWidget);
    expect(find.text('Duplicate response.'), findsNothing);

    notificationService.dismiss();
  });

  testWidgets('403 notification does not clear the active session', (
    tester,
  ) async {
    final notificationService = AppNotificationService();
    final navigatorKey = GlobalKey<NavigatorState>();
    final sessionStore = SessionStore()
      ..saveSession(accessToken: 'token', role: 'User');

    await _pumpHarness(
      tester,
      notificationService: notificationService,
      navigatorKey: navigatorKey,
    );

    AppErrorHandler(
      notificationService: notificationService,
    ).showApiException(
      const ApiException(statusCode: 403, message: 'Admins only.'),
    );
    await tester.pump();

    expect(sessionStore.isAuthenticated, isTrue);
    expect(find.text('Home page'), findsOneWidget);
    expect(find.text('Admins only.'), findsOneWidget);

    notificationService.dismiss();
  });
}

Future<void> _pumpHarness(
  WidgetTester tester, {
  required AppNotificationService notificationService,
  required GlobalKey<NavigatorState> navigatorKey,
}) {
  return tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (_) => const Scaffold(body: Text('Home page')),
        '/login': (_) => const Scaffold(body: Text('Login page')),
      },
      builder: (context, child) {
        return AppNotificationOverlay(
          notificationService: notificationService,
          child: child ?? const SizedBox.shrink(),
        );
      },
    ),
  );
}
