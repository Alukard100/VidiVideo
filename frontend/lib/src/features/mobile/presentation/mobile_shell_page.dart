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

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
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

