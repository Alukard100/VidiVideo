import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../models/notification_item.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
  });

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<NotificationItem>> _notificationsFuture;

  Timer? _pollTimer;

  bool _isMarkingAllRead = false;

  @override
  void initState() {
    super.initState();

    _notificationsFuture = _getNotifications();

    // Automatski refresh notifikacija.
    _pollTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) {
        _refreshNotificationsSilently();
      },
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<List<NotificationItem>> _getNotifications() {
    return AppServices.notificationService.getNotifications();
  }

  Future<void> _refreshNotifications() async {
    final future = _getNotifications();

    setState(() {
      _notificationsFuture = future;
    });

    await future;
  }

  Future<void> _refreshNotificationsSilently() async {
    try {
      final notifications = await _getNotifications();

      if (!mounted) {
        return;
      }

      setState(() {
        _notificationsFuture =
            Future.value(notifications);
      });
    } catch (_) {
      // Polling error ne treba rušiti trenutno prikazanu listu.
    }
  }

  Future<void> _markAsRead(
    NotificationItem notification,
  ) async {
    if (notification.isRead) {
      return;
    }

    try {
      await AppServices.notificationService
          .markAsRead(notification.id);

      if (!mounted) {
        return;
      }

      await _refreshNotifications();
    } on ApiException catch (exception) {
      _showMessage(
        'Could not mark notification as read '
        '(${exception.statusCode}): ${exception.message}',
      );
    } catch (exception) {
      _showMessage(
        'Could not mark notification as read: $exception',
      );
    }
  }

  Future<void> _markAllAsRead() async {
    if (_isMarkingAllRead) {
      return;
    }

    setState(() {
      _isMarkingAllRead = true;
    });

    try {
      await AppServices.notificationService
          .markAllAsRead();

      if (!mounted) {
        return;
      }

      await _refreshNotifications();

      _showMessage(
        'All notifications marked as read.',
      );
    } on ApiException catch (exception) {
      _showMessage(
        'Could not mark notifications as read '
        '(${exception.statusCode}): ${exception.message}',
      );
    } catch (exception) {
      _showMessage(
        'Could not mark notifications as read: $exception',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingAllRead = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                _isMarkingAllRead
                    ? null
                    : _markAllAsRead,
            child: _isMarkingAllRead
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Mark all read',
                  ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: FutureBuilder<List<NotificationItem>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return _NotificationsError(
                message:
                    snapshot.error.toString(),
                onRetry: _refreshNotifications,
              );
            }

            final notifications =
                snapshot.data ?? const [];

            if (notifications.isEmpty) {
              return const _EmptyNotifications();
            }

            return ListView.separated(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(
                vertical: 8,
              ),
              itemCount: notifications.length,
              separatorBuilder:
                  (context, index) =>
                      const Divider(
                height: 1,
                indent: 72,
              ),
              itemBuilder: (context, index) {
                final notification =
                    notifications[index];

                return _NotificationTile(
                  notification: notification,
                  onPressed: () =>
                      _markAsRead(notification),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onPressed,
  });

  final NotificationItem notification;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Material(
      color: isUnread
          ? const Color(0xFFF3F4F6)
          : Colors.white,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            14,
            16,
            14,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _NotificationIcon(
                type: notification.type,
                isUnread: isUnread,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color:
                                  const Color(
                                0xFF111827,
                              ),
                              fontSize: 15,
                              fontWeight:
                                  isUnread
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          const Padding(
                            padding:
                                EdgeInsets.only(
                              top: 4,
                            ),
                            child: CircleAvatar(
                              radius: 4,
                              backgroundColor:
                                  Color(
                                0xFF2563EB,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (notification.body
                        .trim()
                        .isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: const TextStyle(
                          color:
                              Color(0xFF4B5563),
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _formatRelativeTime(
                        notification.createdAtUtc,
                      ),
                      style: const TextStyle(
                        color:
                            Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(
    DateTime? value,
  ) {
    if (value == null) {
      return '';
    }

    final now = DateTime.now().toUtc();
    final date = value.toUtc();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day.$month.${date.year}';
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({
    required this.type,
    required this.isUnread,
  });

  final String type;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 21,
      backgroundColor: isUnread
          ? const Color(0xFFE0E7FF)
          : const Color(0xFFF3F4F6),
      child: Icon(
        _iconForType(type),
        size: 21,
        color: const Color(0xFF374151),
      ),
    );
  }

  IconData _iconForType(String type) {
    final normalized = type.toLowerCase();

    if (normalized.contains('like')) {
      return Icons.favorite_outline_rounded;
    }

    if (normalized.contains('comment')) {
      return Icons.mode_comment_outlined;
    }

    if (normalized.contains('follow')) {
      return Icons.person_add_alt_1_outlined;
    }

    if (normalized.contains('subscription') ||
        normalized.contains('subscribe')) {
      return Icons.workspace_premium_outlined;
    }

    if (normalized.contains('report')) {
      return Icons.flag_outlined;
    }

    if (normalized.contains('video')) {
      return Icons.play_circle_outline_rounded;
    }

    return Icons.notifications_none_rounded;
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 180),
        Icon(
          Icons.notifications_none_rounded,
          size: 54,
          color: Color(0xFF9CA3AF),
        ),
        SizedBox(height: 14),
        Center(
          child: Text(
            'No notifications yet.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationsError extends StatelessWidget {
  const _NotificationsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 140),
        const Icon(
          Icons.error_outline_rounded,
          size: 48,
          color: Color(0xFF9CA3AF),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: () {
              onRetry();
            },
            child: const Text('Try again'),
          ),
        ),
      ],
    );
  }
}