

import 'package:flutter/material.dart';

import '../../models/video_detail.dart';

class VideoCaption extends StatelessWidget {
  const VideoCaption({required this.video, super.key});

  final VideoDetail video;

  @override
  Widget build(BuildContext context) {
    final hashtags = video.hashtags.map((tag) => '#$tag').join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          video.creatorName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          video.caption,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
        if (hashtags.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            hashtags,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}