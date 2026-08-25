import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/network/media_url.dart';

class VideoSurface extends StatelessWidget {
  const VideoSurface({
    required this.controller,
    required this.thumbnailUrl,
    required this.onTap,
    required this.onDoubleTap,
    super.key,
  });

  final VideoPlayerController? controller;
  final String thumbnailUrl;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final activeController = controller;

    if (activeController != null &&
        activeController.value.isInitialized) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: activeController.value.size.width,
            height: activeController.value.size.height,
            child: VideoPlayer(activeController),
          ),
        ),
      );
    }

    final resolvedThumbnail =
        resolveMediaUrl(thumbnailUrl);

    if (resolvedThumbnail.isEmpty) {
      return const ColoredBox(
        color: Colors.black,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onDoubleTap: onDoubleTap,
      child: Image.network(
        resolvedThumbnail,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return const ColoredBox(
            color: Colors.black,
          );
        },
      ),
    );
  }
}