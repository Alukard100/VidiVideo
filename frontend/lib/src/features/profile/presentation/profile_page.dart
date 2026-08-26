import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../payments/presentation/paypal_checkout_page.dart';
import '../../payments/presentation/paypal_onboarding_page.dart';
import '../../profile/models/follow_user.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/presentation/sheets/change_password_sheet.dart';
import '../../profile/presentation/sheets/edit_profile_sheet.dart';
import '../../profile/presentation/sheets/follow_list_sheet.dart';
import '../../profile/presentation/widgets/profile_error.dart';
import '../../profile/presentation/widgets/profile_header.dart';
import '../../profile/presentation/widgets/profile_tabs.dart';
import '../../notifications/presentation/notifications_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    this.userId,
    super.key,
  });

  final String? userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = AppServices.profileService;

  late Future<UserProfile> _profileFuture;
  bool _showPublicPreview = false;

  bool get _isMyProfile => widget.userId == null && !_showPublicPreview;
  bool get _isVisitingProfile => widget.userId != null || _showPublicPreview;

  bool _hasUnreadNotifications = false;
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();

    AppServices.profileRefreshNotifier.addListener(_refreshProfile);

    _refreshNotificationBadge();

    _notificationTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _refreshNotificationBadge(),
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();

    AppServices.profileRefreshNotifier.removeListener(_refreshProfile);
    super.dispose();
  }

  Future<UserProfile> _loadProfile() {
    final userId = widget.userId;

    if (userId == null || _showPublicPreview) {
      return _profileService.getMyProfile();
    }

    return _profileService.getProfile(userId);
  }

  Future<void> _handleProfileMenuAction(
    _ProfileMenuAction action,
  ) async {
    switch (action) {
      case _ProfileMenuAction.changePassword:
        await _openChangePassword();
        break;

      case _ProfileMenuAction.logout:
        await _logout();
        break;
    }
  }

  Future<void> _openChangePassword() async {
    final changed =
        await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) =>
          const ChangePasswordSheet(),
    );

    if (!mounted) {
      return;
    }

    if (changed == true) {
      _showMessage(
        'Password changed successfully.',
      );
    }
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null) {
      _showMessage('Could not read the selected avatar.');
      return;
    }

    const maximumSize = 5 * 1024 * 1024;

    if (file.size > maximumSize) {
      _showMessage('Avatar must not be larger than 5 MB.');
      return;
    }

    try {
      await _profileService.uploadAvatar(
        bytes: bytes,
        fileName: file.name,
      );

      if (!mounted) {
        return;
      }

      _showMessage('Avatar updated.');
      _refreshProfile();
    } on ApiException catch (exception) {
      _showMessage('Avatar upload failed (${exception.statusCode}): ${exception.message}');
    } catch (exception) {
      _showMessage('Avatar upload failed: $exception');
    }
  }

  Future<void> _openEditProfile(UserProfile profile) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return EditProfileSheet(profile: profile);
      },
    );

    if (updated == true) {
      _refreshProfile();
    }
  }
  Future<void> _toggleFollow(UserProfile profile) async {
    if (!_hasSession()) {
      _openRegister();
      return;
    }

    try {
      if (profile.isFollowing) {
        await _profileService.unfollow(profile.id);
      } else {
        await _profileService.follow(profile.id);
      }

      AppServices.feedRefreshNotifier.refreshFollowing();

      if (!mounted) {
        return;
      }

      _refreshProfile();
    } on ApiException catch (exception) {
      if (_redirectToRegisterIfAuthRequired(exception)) {
        return;
      }

      _showMessage(
        'Follow action failed '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (exception) {
      _showMessage(
        'Follow action failed: $exception',
      );
    }
  }

  Future<void> _followFromList(FollowUser user) async {
    try {
      await _profileService.follow(user.id);

      AppServices.feedRefreshNotifier.refreshFollowing();

      if (!mounted) {
        return;
      }

      _showMessage(
        'Now following '
        '${user.displayName.isEmpty ? 'user' : user.displayName}.',
      );

      _refreshProfile();
    } on ApiException catch (exception) {
      if (_redirectToRegisterIfAuthRequired(exception)) {
        return;
      }

      _showMessage(
        'Follow failed '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (exception) {
      _showMessage('Follow failed: $exception');
    }
  }

  void _subscribe(UserProfile profile) async {
  if (!_hasSession()) {
    _openRegister();
    return;
  }

  try {
    final order =
      await AppServices.payPalPaymentService
          .createOrder(profile.id);

      if (!mounted) {
        return;
      }

      final approved =
          await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              PayPalCheckoutPage(
            approvalUrl: order.approvalUrl,
          ),
        ),
      );

      if (approved != true) {
        return;
      }

      final captured =
          await AppServices.payPalPaymentService
              .captureOrder(order.orderId);

      if (!mounted) {
        return;
      }

      if (!captured) {
        _showMessage(
          'Payment could not be completed.',
        );
        return;
      }

      _showMessage(
        'Subscription activated.',
      );

      _refreshProfile();
    } on ApiException catch (exception) {
      _showMessage(
        'Subscription failed '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (exception) {
      _showMessage(
        'Subscription failed: $exception',
      );
    }
  }

  Future<void> _openFollowList(UserProfile profile, _FollowListType type) async {
    if (!_hasSession()) {
      _openRegister();
      return;
    }

    final currentUser = await _profileService.getMyProfile();

    if (!mounted) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return FollowListSheet(
          title: type == _FollowListType.followers ? 'Followers' : 'Following',

          usersFuture: type == _FollowListType.followers
            ? _profileService.getFollowers(
                currentUserId: currentUser.id,
                targetUserId: profile.id,
              )
            : _profileService.getFollowing(
                currentUserId: currentUser.id,
                targetUserId: profile.id,
            ),

          allowFollowActions:
                _isMyProfile &&
                type == _FollowListType.followers,

          onFollowPressed: (user) async {
            await _followFromList(user);

            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },

          onUserPressed: (user) {
            Navigator.of(context).pop();
            AppServices.mobileNavigation.openUserProfile(user.id);
          },
        );
      },
    );
  }

  Future<void> _requestRefund(
    UserProfile profile,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Request refund?',
          ),
          content: Text(
            'Do you want to request a refund '
            'for your subscription to '
            '${profile.displayName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Request refund',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    try {
      await AppServices.refundService
          .requestRefund(
        creatorId: profile.id,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Refund request submitted.',
      );
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Refund request failed '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Refund request failed.',
      );
    }
  }

  bool _hasSession() {
    final token = AppServices.sessionStore.accessToken;
    return token != null && token.isNotEmpty;
  }

  void _openRegister() {
    Navigator.of(context).pushNamed(AppRoutes.register);
  }

  bool _redirectToRegisterIfAuthRequired(ApiException exception) {
    if (exception.statusCode != 401 && exception.statusCode != 403) {
      return false;
    }

    _openRegister();
    return true;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF111827),
            elevation: 0,
            centerTitle: false,
            leading: _isVisitingProfile
                ? IconButton(
                    tooltip: 'Back',
                    onPressed: () {
                      if (_showPublicPreview) {
                        setState(() {
                          _showPublicPreview = false;
                          _profileFuture = _loadProfile();
                        });
                      } else if (AppServices.mobileNavigation.activeOverlay != null) {
                        AppServices.mobileNavigation.closeOverlay();
                      } else {
                        Navigator.of(context).maybePop();
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                  )
                : null,
            title: Text(
              profile?.userName ?? (_isMyProfile ? 'my profile' : 'profile'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              if (widget.userId == null) ...[
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: _openNotifications,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                      ),

                      if (_hasUnreadNotifications)
                        const Positioned(
                          right: -1,
                          top: -1,
                          child: CircleAvatar(
                            radius: 4,
                            backgroundColor: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ),

                IconButton(
                  tooltip: _showPublicPreview ? 'Show editable profile' : 'Preview public profile',
                  onPressed: () {
                    setState(() {
                      _showPublicPreview = !_showPublicPreview;
                      _profileFuture = _loadProfile();
                    });
                  },
                  icon: Icon(_showPublicPreview ? Icons.edit_outlined : Icons.visibility_outlined),
                ),

                PopupMenuButton<_ProfileMenuAction>(
                  onSelected: _handleProfileMenuAction,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _ProfileMenuAction.changePassword,
                      child: Text('Change password'),
                    ),
                    PopupMenuItem(
                      value: _ProfileMenuAction.logout,
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ],               
            ],
          ),
          body: _buildBody(snapshot),
        );
      },
    );
  }

  Future<void> _logout() async {
    AppServices.sessionStore.clearSession();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  Widget _buildBody(AsyncSnapshot<UserProfile> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return ProfileError(
        message: snapshot.error.toString(),
        onRetry: _refreshProfile,
      );
    }

    final profile = snapshot.data;

    if (profile == null) {
      return ProfileError(
        message: 'Profile could not be loaded.',
        onRetry: _refreshProfile,
      );
    }

    final publicVideos = _showPublicPreview
        ? profile.publicVideos
            .where((video) => video.isPublished)
            .toList()
        : profile.publicVideos;

    final subscriberOnlyVideos = _showPublicPreview
        ? profile.subscriberOnlyVideos
            .where((video) => video.isPublished)
            .toList()
        : profile.subscriberOnlyVideos;


    return RefreshIndicator(
      onRefresh: () async => _refreshProfile(),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                children: [
                  ProfileHeader(
                    profile: profile,
                    isMyProfile: _isMyProfile,
                    isVisitingProfile: _isVisitingProfile,
                    isPreview: _showPublicPreview,
                    onEditProfile: () => _openEditProfile(profile),
                    onChangeAvatar: _pickAvatar,
                    onConnectPayPal: _connectPayPal,
                    onFollowersPressed: () => _openFollowList(profile, _FollowListType.followers),
                    onFollowingPressed: () => _openFollowList(profile, _FollowListType.following),
                    onFollow: () => _toggleFollow(profile),
                    onSubscribe: () => _subscribe(profile),
                    onRefund: () => _requestRefund(profile),
                  ),
                  const SizedBox(height: 16),
                  ProfileTabs(
                    profileId: profile.id,
                    publicVideos: publicVideos,
                    subscriberOnlyVideos: subscriberOnlyVideos,
                    forceSubscriberLocks: _isVisitingProfile && !profile.isSubscribed,
                    showUnpublishedStatus: _isMyProfile,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshNotificationBadge() async {
    try {
      final notifications =
          await AppServices.notificationService
              .getNotifications(
        page: 1,
        pageSize: 50,
      );

      final hasUnread =
          notifications.any((n) => !n.isRead);

      if (!mounted) {
        return;
      }

      setState(() {
        _hasUnreadNotifications = hasUnread;
      });
    } catch (_) {
      // Badge failure ne treba rušiti profile page.
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const NotificationsPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    await _refreshNotificationBadge();
  }

  Future<void> _connectPayPal() async {
    try {
      final onboardingUrl =
          await AppServices
              .payPalPaymentService
              .createOnboarding();

      if (!mounted) {
        return;
      }

      final completed =
          await Navigator.of(context)
              .push<bool>(
        MaterialPageRoute(
          builder: (_) =>
              PayPalOnboardingPage(
            onboardingUrl:
                onboardingUrl,
          ),
        ),
      );

      if (completed != true ||
          !mounted) {
        return;
      }

      final connected =
          await AppServices
              .payPalPaymentService
              .completeOnboarding();

      if (!mounted) {
        return;
      }

      if (!connected) {
        _showMessage(
          'PayPal connection could not be verified.',
        );
        return;
      }

      _showMessage(
        'PayPal connected successfully.',
      );

      AppServices.profileRefreshNotifier.refresh();

      _refreshProfile();
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'PayPal connection failed '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (exception) {
      if (!mounted) {
        return;
      }

      debugPrint(
        'PAYPAL CONNECT ERROR: $exception',
      );

      _showMessage(
        'Unable to connect PayPal.',
      );
    }
  }
}

enum _FollowListType { followers, following }

enum _ProfileMenuAction {
  changePassword,
  logout,
}

