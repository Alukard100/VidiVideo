import 'dart:async';

import 'package:flutter/material.dart';

class AppNotificationOverlay extends StatefulWidget {
  const AppNotificationOverlay({
    required this.notificationService,
    required this.child,
    super.key,
  });

  final AppNotificationService notificationService;
  final Widget child;

  @override
  State<AppNotificationOverlay> createState() =>
      _AppNotificationOverlayState();
}

class _AppNotificationOverlayState extends State<AppNotificationOverlay> {
  late final OverlayEntry _appEntry;

  @override
  void initState() {
    super.initState();
    _appEntry = OverlayEntry(builder: (_) => widget.child);
  }

  @override
  void didUpdateWidget(AppNotificationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _appEntry.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: widget.notificationService.overlayKey,
      initialEntries: [_appEntry],
    );
  }
}

class AppNotificationService {
  AppNotificationService();

  final overlayKey = GlobalKey<OverlayState>();

  OverlayEntry? _currentEntry;
  Timer? _dismissTimer;

  void showError({
    required String message,
    String? title,
    int? statusCode,
    Duration duration = const Duration(seconds: 6),
  }) {
    _show(
      message: message,
      title: title ?? 'Something went wrong',
      statusCode: statusCode,
      duration: duration,
    );
  }

  void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }

  void _show({
    required String message,
    required String title,
    required Duration duration,
    int? statusCode,
  }) {
    final overlay = overlayKey.currentState;

    if (overlay == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _show(
          message: message,
          title: title,
          duration: duration,
          statusCode: statusCode,
        );
      });
      return;
    }

    dismiss();

    final entry = OverlayEntry(
      builder: (context) => _AppErrorNotification(
        message: message,
        title: title,
        statusCode: statusCode,
        onDismiss: dismiss,
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
    _dismissTimer = Timer(duration, dismiss);
  }
}

class _AppErrorNotification extends StatelessWidget {
  const _AppErrorNotification({
    required this.message,
    required this.title,
    required this.onDismiss,
    this.statusCode,
  });

  final String message;
  final String title;
  final int? statusCode;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Positioned(
      top: MediaQuery.paddingOf(context).top + 12,
      left: 12,
      right: 12,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.up,
              onDismissed: (_) => onDismiss(),
              child: Semantics(
                container: true,
                liveRegion: true,
                label: '$title. $message',
                child: Material(
                  color: colors.errorContainer,
                  elevation: 10,
                  shadowColor: Colors.black45,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: colors.onErrorContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: colors.onErrorContainer,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (statusCode != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.error.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'HTTP $statusCode',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: colors.onErrorContainer,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onErrorContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Dismiss',
                          visualDensity: VisualDensity.compact,
                          onPressed: onDismiss,
                          icon: Icon(
                            Icons.close_rounded,
                            color: colors.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
