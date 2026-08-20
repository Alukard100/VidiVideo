import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoProgressBar extends StatelessWidget {
  const VideoProgressBar({
    required this.controller,
    super.key,
  });

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final activeController = controller;

    if (activeController == null ||
        !activeController.value.isInitialized) {
      return const SizedBox(height: 2);
    }

    return SizedBox(
      height: 2,
      child: VideoProgressIndicator(
        activeController,
        allowScrubbing: true,
        padding: EdgeInsets.zero,
        colors: const VideoProgressColors(
          playedColor: Colors.white,
          bufferedColor: Colors.white38,
          backgroundColor: Colors.white12,
        ),
      ),
    );
  }
}