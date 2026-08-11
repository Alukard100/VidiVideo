import 'package:flutter/material.dart';

enum FeedMode { recommended, following }

class FeedPage extends StatelessWidget {
  const FeedPage({this.feedMode = FeedMode.recommended, super.key});

  final FeedMode feedMode;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: PageView.builder(
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
                      const Spacer(),
                      Text(
                        feedMode == FeedMode.following ? 'Following feed' : 'Recommended feed',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '@creator${index + 1}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Short video caption with hashtags, like/comment/report actions, and recommendation explanation.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
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
    );
  }
}
