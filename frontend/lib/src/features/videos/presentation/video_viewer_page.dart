import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../app/app_routes.dart';
import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/media_url.dart';
import '../models/video_detail.dart';
import 'sheets/comments_sheet.dart';
import 'sheets/edit_video_sheet.dart';
import 'sheets/report_content_dialog.dart';
import 'widgets/video_page_surface.dart';


class VideoViewerPage extends StatefulWidget {
  const VideoViewerPage({
    String? videoId,
    List<String>? videoIds,
    String? initialVideoId,
    this.initialVideos = const [],
    this.showBackButton = true,
    this.sourceCreatorId,
    this.showRecommendationReason = false,
    this.isActive = true,
    
    super.key,
  })  : videoIds = videoIds ?? const [],
        initialVideoId = initialVideoId ?? videoId ?? '';

  final bool showRecommendationReason;
  final List<String> videoIds;
  final String initialVideoId;
  final List<VideoDetail> initialVideos;
  final bool showBackButton;
  final String? sourceCreatorId;
  final bool isActive;

  @override
  State<VideoViewerPage> createState() => _VideoViewerPageState();
}

class _VideoViewerPageState extends State<VideoViewerPage> {
  final _videoService = AppServices.videoService;

  late final PageController _pageController;
  late final List<String> _videoIds;
  late Future<VideoDetail> _videoFuture;
  final Map<String, Future<VideoDetail>> _videoFutures = {};
  final Map<String, VideoDetail> _videoDetails = {};
  final Map<String, String?> _recommendationReasons = {};
  VideoPlayerController? _controller;
  String? _loadedVideoUrl;
  DateTime? _openedAtUtc;
  String? _activeVideoId;
  bool _recordedView = false;
  bool _isLiked = false;
  bool _isMuted = false;
  int _likeCount = 0;
  int _commentCount = 0;
  int _currentIndex = 0;

  VideoDetail? get _activeVideo {
    final videoId = _activeVideoId;

    if (videoId == null) {
      return null;
    }

    return _videoDetails[videoId];
  }

  bool get _isActiveVideoLocked => _activeVideo?.isLocked == true;


  @override
  void initState() {
    super.initState();
    _videoIds = widget.videoIds.isEmpty ? [widget.initialVideoId] : widget.videoIds;

    for (final video in widget.initialVideos) {
      if (video.id.isNotEmpty) {
        _videoDetails[video.id] = video;

        _recommendationReasons[video.id] = video.recommendationReason;
      }
    }

    _currentIndex = _videoIds.indexOf(widget.initialVideoId);
    if (_currentIndex < 0) {
      _currentIndex = 0;
    }
    _pageController = PageController(initialPage: _currentIndex);
    
    _videoFuture = _loadVideo(_videoIds[_currentIndex]);

    _preloadNextVideo(_currentIndex);
  }

  @override
  void dispose() {
    _recordVideoView();
    _controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isActiveVideoLocked) {
      return;
    }

    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<VideoDetail> _loadVideo(String videoId) async {
    _recordVideoView();

    final previousController = _controller;
    _controller = null;
    _loadedVideoUrl = null;

    if (previousController != null && mounted) {
      setState(() {});
    }

    await previousController?.dispose();

    if (videoId.isEmpty) {
      throw const ApiException(
        statusCode: 404,
        message: 'Video could not be loaded.',
      );
    }

    _activeVideoId = videoId;
    _recordedView = false;
    _openedAtUtc = DateTime.now().toUtc();

    final video = await _getVideoFuture(videoId);

    if (!mounted || _activeVideoId != videoId) {
      return video;
    }

    setState(() {
      _likeCount = video.likeCount;
      _commentCount = video.commentCount;
      _isLiked = video.isLiked;
    });

    if (video.isLocked) {
      _openedAtUtc = null;
      _recordedView = true;

      return video;
    }

    if (!video.isLocked &&
        video.videoUrl != null &&
        video.videoUrl!.isNotEmpty) {
      await _prepareController(video.videoUrl!);
    }

    return video;

  }

  Future<VideoDetail> _getVideoFuture(String videoId) {
    final existing = _videoDetails[videoId];

    if (existing != null) {
      return Future.value(existing);
    }

    return _videoFutures.putIfAbsent(
      videoId,
      () async {
        final video = await _videoService.getVideo(videoId);
        _videoDetails[videoId] = video;
        return video;
      },
    );
  }

  Future<void> _prepareController(
    String videoUrl,
    ) async {
    final resolvedUrl =
        resolveMediaUrl(videoUrl);

    if (resolvedUrl.isEmpty ||
        resolvedUrl == _loadedVideoUrl) {
      return;
    }

    final controller =
        VideoPlayerController.networkUrl(
      Uri.parse(resolvedUrl),
      httpHeaders: _streamHeaders(),
    );

    _loadedVideoUrl = resolvedUrl;
    _controller = controller;

    await controller.initialize();

    if (!mounted ||
        _controller != controller) {
      await controller.dispose();
      return;
    }

    await controller.setLooping(true);
    await controller.setVolume(
      _isMuted ? 0 : 1,
    );

    if (widget.isActive) {
      await controller.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Map<String, String> _streamHeaders() {
    final token = AppServices.sessionStore.accessToken;

    if (token == null || token.isEmpty) {
      return const {};
    }

    return {'Authorization': 'Bearer $token'};
  }

  Future<void> _showCaughtUpPage() async {
    _recordVideoView();

    final previousController = _controller;

    if (!mounted) {
      await previousController?.dispose();
      return;
    }

    setState(() {
      _controller = null;
      _loadedVideoUrl = null;
      _activeVideoId = null;
      _recordedView = true;
    });

    await previousController?.dispose();
  }

  void _recordVideoView() {
    if (_recordedView) {
      return;
    }

    final openedAtUtc = _openedAtUtc;
    final videoId = _activeVideoId;

    if (openedAtUtc == null || videoId == null || videoId.isEmpty) {
      return;
    }

    _recordedView = true;

    final watchedSeconds = DateTime.now().toUtc().difference(openedAtUtc).inSeconds;
    final controller = _controller;
    final duration = controller?.value.duration.inSeconds ?? 0;
    final completionRate = duration <= 0 ? 0.0 : (watchedSeconds / duration).clamp(0.0, 1.0);

    unawaited(
      _videoService.recordVideoView(
        videoId: videoId,
        watchDurationSeconds: watchedSeconds < 1 ? 1 : watchedSeconds,
        completionRate: completionRate,
      ).catchError((_) {}),
    );
  }

  Future<void> _toggleLike() async {
    if (_isActiveVideoLocked) {
      return;
    }
    final videoId = _activeVideoId;

    if (videoId == null) {
      return;
    }

    final nextLiked = !_isLiked;

    setState(() {
      _isLiked = nextLiked;

      if (nextLiked) {
          _likeCount++;
        } else if (_likeCount > 0) {
          _likeCount--;
        }
      });

      final cachedVideo = _videoDetails[videoId];

      if (cachedVideo != null) {
        _videoDetails[videoId] = cachedVideo.copyWith(
          isLiked: nextLiked,
          likeCount: _likeCount,
        );
      }

    try {
      if (nextLiked) {
        await _videoService.likeVideo(videoId);
      } else {
        await _videoService.unlikeVideo(videoId);
      }
    } on ApiException catch (exception) {
      _rollbackLike(nextLiked);
      if (_redirectToRegisterIfAuthRequired(exception)) {
        return;
      }
      _showMessage('Like action failed (${exception.statusCode}): ${exception.message}');
    } catch (exception) {
      _rollbackLike(nextLiked);
      _showMessage('Like action failed: $exception');
    }
  }

  Future<void> _likeVideo() async {
    if (_isActiveVideoLocked || _isLiked) {
    return;
  }

    await _toggleLike();
  }

  void _rollbackLike(bool failedLikedState) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLiked = !failedLikedState;
      if (failedLikedState) {
      if (_likeCount > 0) {
          _likeCount--;
        }
      } else {
        _likeCount++;
      }
    });

    final videoId = _activeVideoId;

    if (videoId != null) {
      final cachedVideo = _videoDetails[videoId];

      if (cachedVideo != null) {
        _videoDetails[videoId] = cachedVideo.copyWith(
          isLiked: _isLiked,
          likeCount: _likeCount,
        );
      }
    }
  }

  void _preloadNextVideo(int currentIndex) {
    final nextIndex = currentIndex + 1;

    if (nextIndex >= _videoIds.length) {
      return;
    }

    unawaited(
      _preloadVideoAssets(_videoIds[nextIndex]),
    );
  }

  Future<void> _preloadVideoAssets(String videoId) async {
    try {
      final video = await _getVideoFuture(videoId);

      if (!mounted) {
        return;
      }

      final thumbnailUrl =
          resolveMediaUrl(video.thumbnailUrl);

      if (thumbnailUrl.isNotEmpty) {
        await precacheImage(
          NetworkImage(thumbnailUrl),
          context,
        );
      }

      final avatarUrl =
          resolveMediaUrl(video.creatorAvatarUrl);

      if (avatarUrl.isNotEmpty && mounted) {
        await precacheImage(
          NetworkImage(avatarUrl),
          context,
        );
      }
    } catch (_) {
      // Preloading failure should never break the feed.
    }
  }

  Future<void> _openComments() async {
    if (_isActiveVideoLocked) {
      return;
    }

    final videoId = _activeVideoId;

    if (videoId == null) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (context) => CommentsSheet(
        videoId: videoId,
        onCommentAdded: () {
          if (!mounted) {
            return;
          }

          setState(() {
            _commentCount++;
          });
        },
      ),
    );
  }

  Future<void> _reportVideo() async {
    if (_isActiveVideoLocked) {
      return;
    }

    final videoId = _activeVideoId;

    if (videoId == null) {
      return;
    }

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const ReportContentDialog(
        title: 'Report video',
      ),
    );

    if (reason == null || reason.trim().isEmpty) {
      return;
    }

    try {
      await _videoService.reportVideo(
        videoId: videoId,
        reason: reason.trim(),
      );
      _showMessage('Report submitted.');
    } on ApiException catch (exception) {
      if (_redirectToRegisterIfAuthRequired(exception)) {
        return;
      }
      _showMessage('Report failed (${exception.statusCode}): ${exception.message}');
    } catch (exception) {
      _showMessage('Report failed: $exception');
    }
  }

  Future<void> _showCreatorProfile(VideoDetail video) async {
    await _controller?.pause();
    AppServices.mobileNavigation.openUserProfile(video.creatorId);
  }

  Future<void> _editVideo(VideoDetail video) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (context) => EditVideoSheet(video: video),
    );

    if (updated != true || !mounted) {
      return;
    }

    setState(() {
      _videoDetails.remove(video.id);
      _videoFutures.remove(video.id);
      _videoFuture = _loadVideo(video.id);
    });
  }

  Future<void> _toggleMute() async {
    if (_isActiveVideoLocked) {
      return;
    }

    final controller = _controller;

    if (controller == null) {
      return;
    }

    setState(() {
      _isMuted = !_isMuted;
    });
    await controller.setVolume(_isMuted ? 0 : 1);
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool _redirectToRegisterIfAuthRequired(ApiException exception) {
    if (exception.statusCode != 401 && exception.statusCode != 403) {
      return false;
    }

    if (!mounted) {
      return true;
    }

    Navigator.of(context).pushNamed(AppRoutes.register);
    return true;
  }

  @override
  void didUpdateWidget(
    covariant VideoViewerPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive !=
        widget.isActive) {
      unawaited(
        _handleActiveStateChanged(),
      );
    }
  }

  Future<void>
      _handleActiveStateChanged() async {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    if (widget.isActive) {
      await controller.play();
    } else {
      await controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: _videoIds.length + 1,
      onPageChanged: (index) {
        if (index >= _videoIds.length) {
          unawaited(_showCaughtUpPage());
          return;
        }

        setState(() {
          _currentIndex = index;
          _videoFuture = _loadVideo(_videoIds[index]);
        });

        _preloadNextVideo(index);
      },
      itemBuilder: (context, index) {
        if (index >= _videoIds.length) {
          return const _CaughtUpPage();
        }

        return VideoPageSurface(
          videoFuture: index == _currentIndex
              ? _videoFuture
              : _getVideoFuture(_videoIds[index]),
          controller: index == _currentIndex ? _controller : null,
          showBackButton: widget.showBackButton,
          isLiked: _isLiked,
          isMuted: _isMuted,
          likeCount: _likeCount,
          commentCount: _commentCount,
          onBack: AppServices.mobileNavigation.closeOverlay,
          onLike: _toggleLike,
          onComments: _openComments,
          onReport: _reportVideo,
          onSound: _toggleMute,
          onEdit: _editVideo,
          onPlaybackTap: _togglePlayback,
          onDoubleTap: _likeVideo,
          onCreator: _showCreatorProfile,
          showRecommendationReason: widget.showRecommendationReason,
          recommendationReason: _recommendationReasons[_videoIds[index]],
        );
      },
    );
  }
}

class _CaughtUpPage extends StatelessWidget {
  const _CaughtUpPage();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 62,
                  width: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .10),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'You are all caught up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check back later for more videos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

