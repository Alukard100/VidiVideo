import 'package:flutter/material.dart';
import '../widgets/vidivideo_bottom_navigation.dart';

import 'create/create_video_page.dart';
import 'feed_page.dart';
import 'profile_page.dart';
import 'search_page.dart';

class MobileShellPage extends StatefulWidget {
  const MobileShellPage({super.key});

  @override
  State<MobileShellPage> createState() => _MobileShellPageState();
}

class _MobileShellPageState extends State<MobileShellPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    FeedPage(),
    SearchPage(),
    CreateVideoPage(),
    FeedPage(feedMode: FeedMode.following),
    ProfilePage(),
  ];

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: VidiVideoBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: _selectPage,
      ),
    );
  }
}

