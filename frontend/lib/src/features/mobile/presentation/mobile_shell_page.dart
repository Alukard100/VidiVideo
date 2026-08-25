import 'package:flutter/material.dart';
import '../../../app/app_routes.dart';
import '../../../core/dependency/app_services.dart';
import '../navigation/mobile_navigation_controller.dart';
import '../widgets/vidivideo_bottom_navigation.dart';

import 'create/create_video_page.dart';
import 'feed_page.dart';
import '../../profile/presentation/profile_page.dart';
import 'search_page.dart';
import '../../videos/presentation/video_viewer_page.dart';

class MobileShellPage extends StatefulWidget {
  const MobileShellPage({super.key});

  @override
  State<MobileShellPage> createState() => _MobileShellPageState();
}

class _MobileShellPageState extends State<MobileShellPage> {
  int _selectedIndex = 0;


  @override
  void initState() {
    super.initState();
    AppServices.mobileNavigation.addListener(_onMobileNavigationChanged);
  }

  @override
  void dispose() {
    AppServices.mobileNavigation.removeListener(_onMobileNavigationChanged);
    super.dispose();
  }

  void _onMobileNavigationChanged() {
    setState(() {});
  }

  void _selectPage(int index) {
    final isGuest = !AppServices.sessionStore.isAuthenticated;

    final requiresAuth =
      index == 2 ||
      index == 3 ||
      index == 4;

    if (isGuest && requiresAuth) {
      Navigator.of(context).pushNamed(AppRoutes.register,);
      return;
    }

    AppServices.mobileNavigation.clearOverlays();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeOverlay =
        AppServices.mobileNavigation.activeOverlay;

    final pages = <Widget>[
      FeedPage(
        isActive:
            _selectedIndex == 0 &&
            activeOverlay == null,
      ),

      const SearchPage(),

      CreateVideoPage(
        onPublished: () {
          setState(() {
            _selectedIndex = 4;
          });
        },
      ),

      FeedPage(
        feedMode: FeedMode.following,
        isActive:
            _selectedIndex == 3 &&
            activeOverlay == null,
      ),

      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),

          if (activeOverlay != null)
            Positioned.fill(
              child: _MobileOverlayHost(
                overlay: activeOverlay,
              ),
            ),
        ],
      ),
      bottomNavigationBar:
          VidiVideoBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _selectPage,
      ),
    );
  }
}

class _MobileOverlayHost extends StatelessWidget {
  const _MobileOverlayHost({required this.overlay});

  final MobileOverlay overlay;

  @override
  Widget build(BuildContext context) {
    final activeOverlay = overlay;

    if (activeOverlay is UserProfileOverlay) {
      return ProfilePage(userId: activeOverlay.userId);
    }

    if (activeOverlay is VideoFeedOverlay) {
      return VideoViewerPage(
        videoIds: activeOverlay.videoIds,
        initialVideoId: activeOverlay.initialVideoId,
        initialVideos: activeOverlay.initialVideos,
        showBackButton: true,
        sourceCreatorId: activeOverlay.sourceCreatorId,
        isActive: true,
      );
    }

    return const SizedBox.shrink();
  }
}

