import 'package:flutter/material.dart';
import '../../../core/dependency/app_services.dart';
import '../navigation/mobile_navigation_controller.dart';
import '../widgets/vidivideo_bottom_navigation.dart';

import 'create/create_video_page.dart';
import 'feed_page.dart';
import 'profile_page.dart';
import 'search_page.dart';
import '../../videos/presentation/video_viewer_page.dart';

class MobileShellPage extends StatefulWidget {
  const MobileShellPage({super.key});

  @override
  State<MobileShellPage> createState() => _MobileShellPageState();
}

class _MobileShellPageState extends State<MobileShellPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    AppServices.mobileNavigation.addListener(_onMobileNavigationChanged);
    _pages = [
      FeedPage(),
      SearchPage(),
      CreateVideoPage(
        onPublished: () {
          setState(() {
            _selectedIndex = 4;
          });
        },
      ),
      FeedPage(feedMode: FeedMode.following),
      ProfilePage(),
    ];
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
    AppServices.mobileNavigation.clearOverlays();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          if (AppServices.mobileNavigation.activeOverlay != null)
            Positioned.fill(
              child: _MobileOverlayHost(
                overlay: AppServices.mobileNavigation.activeOverlay!,
              ),
            ),
        ],
      ),

      bottomNavigationBar: VidiVideoBottomNavigation(
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
      );
    }

    return const SizedBox.shrink();
  }
}

