import 'package:flutter/foundation.dart';

import '../../videos/models/video_detail.dart';

class MobileNavigationController extends ChangeNotifier {
  final List<MobileOverlay> _overlays = [];

  List<MobileOverlay> get overlays => List.unmodifiable(_overlays);
  MobileOverlay? get activeOverlay => _overlays.isEmpty ? null : _overlays.last;

  void openVideoFeed({
    required List<String> videoIds,
    required String initialVideoId,
    List<VideoDetail> initialVideos = const [],
    String? sourceCreatorId,
  }) {
    _overlays.add(
      VideoFeedOverlay(
        videoIds: videoIds,
        initialVideoId: initialVideoId,
        initialVideos: initialVideos,
        sourceCreatorId: sourceCreatorId,
      ),
    );
    notifyListeners();
  }

  void openUserProfile(String userId) {
    final active = activeOverlay;

    if (active is VideoFeedOverlay && active.sourceCreatorId == userId) {
      closeOverlay();
      return;
    }

    final previousProfileIndex = _overlays.lastIndexWhere(
      (overlay) => overlay is UserProfileOverlay && overlay.userId == userId,
    );

    if (previousProfileIndex != -1) {
      _overlays.removeRange(previousProfileIndex + 1, _overlays.length);
    } else {
      _overlays.add(UserProfileOverlay(userId: userId));
    }

    notifyListeners();
  }

  void closeOverlay() {
    if (_overlays.isEmpty) {
      return;
    }

    _overlays.removeLast();
    notifyListeners();
  }

  void clearOverlays() {
    if (_overlays.isEmpty) {
      return;
    }

    _overlays.clear();
    notifyListeners();
  }
}

sealed class MobileOverlay {
  const MobileOverlay();
}

class UserProfileOverlay extends MobileOverlay {
  const UserProfileOverlay({required this.userId});

  final String userId;
}

class VideoFeedOverlay extends MobileOverlay {
  const VideoFeedOverlay({
    required this.videoIds,
    required this.initialVideoId,
    this.initialVideos = const [],
    this.sourceCreatorId,
  });

  final List<String> videoIds;
  final String initialVideoId;
  final List<VideoDetail> initialVideos;
  final String? sourceCreatorId;
}
