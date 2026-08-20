import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/video_detail.dart';
import 'locked_video_overlay.dart';
import 'video_caption.dart';
import 'video_progress_bar.dart';
import 'video_side_actions.dart';
import 'video_surface.dart';

class VideoPageSurface extends StatelessWidget {
  const VideoPageSurface({
    super.key,
    required this.videoFuture,
    required this.controller,
    required this.showBackButton,
    required this.isLiked,
    required this.isMuted,
    required this.likeCount,
    required this.commentCount,
    required this.onBack,
    required this.onLike,
    required this.onComments,
    required this.onReport,
    required this.onSound,
    required this.onEdit,
    required this.onPlaybackTap,
    required this.onDoubleTap,
    required this.onCreator,
    required this.showRecommendationReason,
    required this.recommendationReason,
  });

  final Future<VideoDetail> videoFuture;
  final VideoPlayerController? controller;
  final bool showBackButton;
  final bool isLiked;
  final bool isMuted;
  final int likeCount;
  final int commentCount;
  final VoidCallback onBack;
  final VoidCallback onLike;
  final VoidCallback onComments;
  final VoidCallback onReport;
  final VoidCallback onSound;
  final ValueChanged<VideoDetail> onEdit;
  final VoidCallback onPlaybackTap;
  final VoidCallback onDoubleTap;
  final ValueChanged<VideoDetail> onCreator;
  final bool showRecommendationReason;
  final String? recommendationReason;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoDetail>(
      future: videoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return const ColoredBox(
            color: Colors.black,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return ColoredBox(
            color: Colors.black,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error?.toString() ??
                      'Video could not be loaded.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          );
        }

        final video = snapshot.data!;

        return Stack(
          fit: StackFit.expand,
          children: [
            VideoSurface(
              controller: controller,
              thumbnailUrl: video.thumbnailUrl,
              onTap: onPlaybackTap,
              onDoubleTap: onDoubleTap,
            ),

            const IgnorePointer(child: _VideoGradientOverlay(),),


            if (!video.isLocked &&
                (controller == null ||
                !controller!.value.isInitialized))
              const IgnorePointer(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),

            if (video.isLocked) const LockedVideoOverlay(),
            SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  if (showBackButton)
                    Positioned(
                      left: 12,
                      top: 8,
                      child: IconButton.filledTonal(
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                  
                  if (showRecommendationReason && recommendationReason != null && recommendationReason!.trim().isNotEmpty)
                    Positioned(
                      left: 16,
                      top: showBackButton ? 58 : 14,
                      right: 90,
                      child: _RecommendationReason(reason: recommendationReason!),
                    ),

                  Positioned(
                    right: 14,
                    bottom: 78,
                    child: VideoSideActions(
                      video: video,
                      isLiked: isLiked,
                      isMuted: isMuted,
                      likeCount: likeCount,
                      commentCount: commentCount,
                      onCreatorPressed: () => onCreator(video),
                      onLikePressed: onLike,
                      onCommentsPressed: onComments,
                      onReportPressed: onReport,
                      onSoundPressed: onSound,
                      onEditPressed: video.canEdit ? () => onEdit(video) : null,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 88,
                    bottom: 86,
                    child: VideoCaption(video: video),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: VideoProgressBar(controller: controller),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VideoGradientOverlay extends StatelessWidget {
  const _VideoGradientOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: .20),
            Colors.transparent,
            Colors.black.withValues(alpha: .78),
          ],
          stops: const [0, .48, 1],
        ),
      ),
    );
  }
}

class _RecommendationReason extends StatelessWidget {
  const _RecommendationReason({
    required this.reason,
  });

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.auto_awesome_outlined,
          size: 14,
          color: Colors.white60,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            reason,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}