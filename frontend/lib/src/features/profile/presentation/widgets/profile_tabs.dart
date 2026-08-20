import 'package:flutter/material.dart';

import '../../../../core/dependency/app_services.dart';
import '../../../videos/widgets/video_thumbnail_tile.dart';
import '../../models/profile_video.dart';

class ProfileTabs extends StatelessWidget {
  const ProfileTabs({
    required this.profileId,
    required this.publicVideos,
    required this.subscriberOnlyVideos,
    required this.forceSubscriberLocks,
    required this.showUnpublishedStatus,
  });

  final String profileId;
  final List<ProfileVideo> publicVideos;
  final List<ProfileVideo> subscriberOnlyVideos;
  final bool forceSubscriberLocks;
  final bool showUnpublishedStatus;

  @override
  Widget build(BuildContext context) {
    final tabHeight = _gridHeightFor(
      publicVideos.length > subscriberOnlyVideos.length
          ? publicVideos.length
          : subscriberOnlyVideos.length,
    );

    return Column(
      children: [
        const TabBar(
          indicatorColor: Color(0xFF111827),
          labelColor: Color(0xFF111827),
          unselectedLabelColor: Color(0xFF374151),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(
              icon: Icon(Icons.grid_on_rounded, size: 17),
              text: 'Videos',
            ),
            Tab(
              icon: Icon(Icons.workspace_premium_outlined, size: 17),
              text: 'Subscribers Only',
            ),
          ],
        ),
        SizedBox(
          height: tabHeight,
          child: TabBarView(
            children: [
              _VideoGrid(
                profileId: profileId,
                videos: publicVideos,
                emptyMessage: 'No public videos yet.',
                showUnpublishedStatus: showUnpublishedStatus,
              ),
              _VideoGrid(
                profileId: profileId,
                videos: subscriberOnlyVideos,
                emptyMessage: 'No subscriber-only videos yet.',
                forceLocked: forceSubscriberLocks,
                showUnpublishedStatus: showUnpublishedStatus,
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _gridHeightFor(int itemCount) {
    final rows = itemCount == 0 ? 1 : ((itemCount + 2) / 3).ceil();
    return rows * 162 + (rows - 1) * 4;
  }
}


class _VideoGrid extends StatelessWidget {
  const _VideoGrid({
    required this.profileId,
    required this.videos,
    required this.emptyMessage,
    this.forceLocked = false,
    this.showUnpublishedStatus = false,
  });

  final String profileId;
  final List<ProfileVideo> videos;
  final String emptyMessage;
  final bool forceLocked;
  final bool showUnpublishedStatus;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return _EmptyVideoStrip(message: emptyMessage);
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 10),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: videos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 14,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final video = videos[index];

        return Stack(
          fit: StackFit.expand,
          children: [
            VideoThumbnailTile(
              video: video,
              forceLocked: forceLocked,
              onTap: () {
                AppServices.mobileNavigation.openVideoFeed(
                  videoIds: videos
                      .where(
                        (item) =>
                            !item.isLocked &&
                            !forceLocked,
                      )
                      .map((item) => item.id)
                      .toList(),
                  initialVideoId: video.id,
                  sourceCreatorId: profileId,
                );
              },
            ),

            if (showUnpublishedStatus &&
                !video.isPublished)
              const IgnorePointer(
                child: _UnpublishedOverlay(),
              ),
          ],
        );
      },
    );
  }
}

class _UnpublishedOverlay extends StatelessWidget {
  const _UnpublishedOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: .48,
        ),
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_off_outlined,
            color: Colors.white,
            size: 27,
          ),
          SizedBox(height: 5),
          Text(
            'Unpublished',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyVideoStrip extends StatelessWidget {
  const _EmptyVideoStrip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF6B7280)),
      ),
    );
  }
}