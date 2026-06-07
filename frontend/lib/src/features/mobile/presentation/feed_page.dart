import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';

enum FeedMode { recommended, following }

class FeedPage extends StatelessWidget {
  const FeedPage({this.feedMode = FeedMode.recommended, super.key});

  final FeedMode feedMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 4,
        itemBuilder: (context, index) {
          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(const Color(0xFF111827), const Color(0xFF2563EB), index / 4)!,
                      const Color(0xFF020617),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton.filledTonal(
                          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.search),
                          icon: const Icon(Icons.search),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        feedMode == FeedMode.following ? 'Following feed' : 'Recommended feed',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '@creator${index + 1}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Short video caption with hashtags, like/comment/report actions, and recommendation explanation.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: feedMode == FeedMode.following ? 3 : 0,
        onDestinationSelected: (index) {
          final route = switch (index) {
            0 => AppRoutes.feed,
            1 => AppRoutes.search,
            2 => AppRoutes.createVideo,
            3 => AppRoutes.following,
            _ => AppRoutes.profile,
          };
          Navigator.of(context).pushReplacementNamed(route);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.add_box_outlined), label: 'Create'),
          NavigationDestination(icon: Icon(Icons.subscriptions_outlined), label: 'Following'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
