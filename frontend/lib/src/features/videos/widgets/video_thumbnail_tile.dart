import 'package:flutter/material.dart';

import '../../../core/network/media_url.dart';
import '../../profile/models/profile_video.dart';

class VideoThumbnailTile extends StatelessWidget {
  const VideoThumbnailTile({
    required this.video,
    this.onTap,
    this.forceLocked = false,
    super.key,
  });

  final ProfileVideo video;
  final VoidCallback? onTap;
  final bool forceLocked;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 14,
      child: InkWell(
        onTap: video.isLocked || forceLocked ? null : onTap,
        borderRadius: BorderRadius.circular(6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _ThumbnailImage(url: video.thumbnailUrl),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: .62),
                    ],
                  ),
                ),
              ),
              if (video.isLocked || forceLocked)
                ColoredBox(
                  color: Colors.black.withValues(alpha: .58),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Subscribe to view',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Text(
                  video.caption.isEmpty ? 'Untitled video' : video.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbnailImage extends StatelessWidget {
  const _ThumbnailImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const _ThumbnailPlaceholder();
    }

    return Image.network(
      resolveMediaUrl(url),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const _ThumbnailPlaceholder();
      },
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF27272A),
            Color(0xFF52525B),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.play_arrow_rounded,
          color: Colors.white70,
          size: 36,
        ),
      ),
    );
  }
}
