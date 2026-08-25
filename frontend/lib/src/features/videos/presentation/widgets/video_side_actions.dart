

import 'package:flutter/material.dart';

import '../../../../core/network/media_url.dart';
import '../../models/video_detail.dart';

class VideoSideActions extends StatelessWidget {
  const VideoSideActions({
    required this.video,
    required this.isLiked,
    required this.isMuted,
    required this.likeCount,
    required this.commentCount,
    required this.onCreatorPressed,
    required this.onLikePressed,
    required this.onCommentsPressed,
    required this.onReportPressed,
    required this.onSoundPressed,
    this.onEditPressed,
    super.key,
  });

  final VideoDetail video;
  final bool isLiked;
  final bool isMuted;
  final int likeCount;
  final int commentCount;
  final VoidCallback onCreatorPressed;
  final VoidCallback onLikePressed;
  final VoidCallback onCommentsPressed;
  final VoidCallback onReportPressed;
  final VoidCallback onSoundPressed;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CreatorButton(
          avatarUrl: video.creatorAvatarUrl,
          onPressed: onCreatorPressed,
        ),

        if (!video.isLocked) ...[
          const SizedBox(height: 18),
          _ActionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            label: _compactNumber(likeCount),
            onPressed: onLikePressed,
          ),
          const SizedBox(height: 18),
          _ActionButton(
            icon: Icons.mode_comment_outlined,
            label: _compactNumber(commentCount),
            onPressed: onCommentsPressed,
          ),
          const SizedBox(height: 18),
          _ActionButton(
            icon: Icons.flag_outlined,
            label: 'Report',
            onPressed: onReportPressed,
          ),
          const SizedBox(height: 18),
          if (onEditPressed != null) ...[
            _ActionButton(
              icon: Icons.edit_outlined,
              label: 'Edit',
              onPressed: onEditPressed!,
            ),
            const SizedBox(height: 18),
          ],
          _ActionButton(
            icon: isMuted ? Icons.volume_off_outlined : Icons.volume_up_outlined,
            label: '',
            onPressed: onSoundPressed,
          ),
        ],
      ],
    );
  }

  String _compactNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }
}


class _CreatorButton extends StatelessWidget {
  const _CreatorButton({
    required this.avatarUrl,
    required this.onPressed,
  });

  final String? avatarUrl;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final resolvedAvatarUrl = resolveMediaUrl(avatarUrl);

    return 
    InkResponse(
      onTap: onPressed,
      radius: 28,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        backgroundImage: resolvedAvatarUrl.isEmpty ? null : NetworkImage(resolvedAvatarUrl),
        child: resolvedAvatarUrl.isEmpty
            ? const Icon(Icons.person, color: Color(0xFF111827))
            : null,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filledTonal(
          onPressed: onPressed,
          icon: Icon(icon),
          color: Colors.white,
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: .28),
          ),
        ),
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}