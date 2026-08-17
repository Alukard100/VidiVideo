import 'package:flutter/material.dart';

import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../videos/models/video_detail.dart';
import '../../videos/presentation/video_viewer_page.dart';

enum FeedMode { recommended, following }

class FeedPage extends StatefulWidget {
  const FeedPage({this.feedMode = FeedMode.recommended, super.key});

  final FeedMode feedMode;

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  late Future<List<VideoDetail>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = _loadVideos();
  }

  @override
  void didUpdateWidget(covariant FeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.feedMode != widget.feedMode) {
      _videosFuture = _loadVideos();
    }
  }

  Future<List<VideoDetail>> _loadVideos() {
    if (widget.feedMode == FeedMode.recommended) {
      return AppServices.videoService.getRecommendedVideos();
    }

    return AppServices.videoService.getFollowingVideos();
  }

  void _retry() {
    setState(() {
      _videosFuture = _loadVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VideoDetail>>(
      future: _videosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ColoredBox(
            color: Colors.black,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _FeedMessage(
            message: _errorMessage(snapshot.error),
            onRetry: _retry,
          );
        }

        final videos = snapshot.data ?? const [];
        final videoIds = videos.map((video) => video.id).toList();

        if (videoIds.isEmpty) {
          return _FeedMessage(
            message: widget.feedMode == FeedMode.recommended
                ? 'No recommended videos yet.'
                : 'No videos available yet.',
            onRetry: _retry,
          );
        }

        return VideoViewerPage(
          videoIds: videoIds,
          initialVideoId: videoIds.first,
          initialVideos: videos,
          showBackButton: false,
        );
      },
    );
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return 'Feed failed (${error.statusCode}): ${error.message}';
    }

    return 'Feed failed: $error';
  }
}

class _FeedMessage extends StatelessWidget {
  const _FeedMessage({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
