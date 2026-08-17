import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/media_url.dart';
import '../models/video_comment.dart';
import '../models/video_detail.dart';

class VideoViewerPage extends StatefulWidget {
  const VideoViewerPage({
    String? videoId,
    List<String>? videoIds,
    String? initialVideoId,
    this.initialVideos = const [],
    this.showBackButton = true,
    this.sourceCreatorId,
    super.key,
  })  : videoIds = videoIds ?? const [],
        initialVideoId = initialVideoId ?? videoId ?? '';

  final List<String> videoIds;
  final String initialVideoId;
  final List<VideoDetail> initialVideos;
  final bool showBackButton;
  final String? sourceCreatorId;

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

  @override
  void initState() {
    super.initState();
    _videoIds = widget.videoIds.isEmpty ? [widget.initialVideoId] : widget.videoIds;
    for (final video in widget.initialVideos) {
      if (video.id.isNotEmpty) {
        _videoDetails[video.id] = video;
      }
    }
    _currentIndex = _videoIds.indexOf(widget.initialVideoId);
    if (_currentIndex < 0) {
      _currentIndex = 0;
    }
    _pageController = PageController(initialPage: _currentIndex);
    _videoFuture = _loadVideo(_videoIds[_currentIndex]);
  }

  @override
  void dispose() {
    _recordVideoView();
    _controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<VideoDetail> _loadVideo(String videoId) async {
    _recordVideoView();

    final previousController = _controller;
    previousController?.removeListener(_onVideoTick);
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
    _isLiked = false;

    final video = await _getVideoFuture(videoId);

    if (_activeVideoId != videoId) {
      return video;
    }

    _likeCount = video.likeCount;
    _commentCount = video.commentCount;
    if (!video.isLocked) {
      await _prepareController(video.videoUrl);
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

  Future<void> _prepareController(String videoUrl) async {
    final resolvedUrl = resolveMediaUrl(videoUrl);

    if (resolvedUrl.isEmpty || resolvedUrl == _loadedVideoUrl) {
      return;
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(resolvedUrl),
      httpHeaders: _streamHeaders(),
    );

    _loadedVideoUrl = resolvedUrl;
    _controller = controller;

    await controller.initialize();
    await controller.setLooping(true);
    await controller.setVolume(_isMuted ? 0 : 1);
    await controller.play();
    controller.addListener(_onVideoTick);

    if (mounted) {
      setState(() {});
    }
  }

  void _onVideoTick() {
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
    previousController?.removeListener(_onVideoTick);

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
    final videoId = _activeVideoId;

    if (videoId == null) {
      return;
    }

    final nextLiked = !_isLiked;

    setState(() {
      _isLiked = nextLiked;
      _likeCount += nextLiked ? 1 : -1;
    });

    try {
      if (nextLiked) {
        await _videoService.likeVideo(videoId);
      } else {
        await _videoService.unlikeVideo(videoId);
      }
    } on ApiException catch (exception) {
      _rollbackLike(nextLiked);
      _showMessage('Like action failed (${exception.statusCode}): ${exception.message}');
    } catch (exception) {
      _rollbackLike(nextLiked);
      _showMessage('Like action failed: $exception');
    }
  }

  void _rollbackLike(bool failedLikedState) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLiked = !failedLikedState;
      _likeCount += failedLikedState ? -1 : 1;
    });
  }

  Future<void> _openComments() async {
    final videoId = _activeVideoId;

    if (videoId == null) {
      return;
    }

    final addedComment = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (context) => _CommentsSheet(videoId: videoId),
    );

    if (addedComment == true && mounted) {
      setState(() {
        _commentCount++;
      });
    }
  }

  Future<void> _reportVideo() async {
    final videoId = _activeVideoId;

    if (videoId == null) {
      return;
    }

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const _ReportDialog(),
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
      _showMessage('Report failed (${exception.statusCode}): ${exception.message}');
    } catch (exception) {
      _showMessage('Report failed: $exception');
    }
  }

  Future<void> _showCreatorProfile(VideoDetail video) async {
    await _controller?.pause();
    AppServices.mobileNavigation.openUserProfile(video.creatorId);
  }

  Future<void> _toggleMute() async {
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
      },
      itemBuilder: (context, index) {
        if (index >= _videoIds.length) {
          return const _CaughtUpPage();
        }

        return _VideoPageSurface(
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
          onCreator: _showCreatorProfile,
        );
      },
    );
  }
}

class _VideoPageSurface extends StatelessWidget {
  const _VideoPageSurface({
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
    required this.onCreator,
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
  final ValueChanged<VideoDetail> onCreator;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoDetail>(
      future: videoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ColoredBox(
            color: Colors.black,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return _VideoError(message: snapshot.error?.toString() ?? 'Video could not be loaded.');
        }

        final video = snapshot.data!;

        return Stack(
          fit: StackFit.expand,
          children: [
            _VideoSurface(
              controller: controller,
              thumbnailUrl: video.thumbnailUrl,
            ),
            _VideoGradientOverlay(),
            if (video.isLocked) const _LockedVideoOverlay(),
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
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 88,
                    bottom: 86,
                    child: _VideoCaption(video: video),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _VideoProgressBar(controller: controller),
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

class _VideoSurface extends StatelessWidget {
  const _VideoSurface({
    required this.controller,
    required this.thumbnailUrl,
  });

  final VideoPlayerController? controller;
  final String thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final activeController = controller;

    if (activeController != null && activeController.value.isInitialized) {
      return GestureDetector(
        onTap: () {
          activeController.value.isPlaying ? activeController.pause() : activeController.play();
        },
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

    final resolvedThumbnail = resolveMediaUrl(thumbnailUrl);

    if (resolvedThumbnail.isEmpty) {
      return const ColoredBox(color: Colors.black);
    }

    return Image.network(
      resolvedThumbnail,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const ColoredBox(color: Colors.black);
      },
    );
  }
}

class _LockedVideoOverlay extends StatelessWidget {
  const _LockedVideoOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: .48),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: Colors.white,
              size: 42,
            ),
            SizedBox(height: 10),
            Text(
              'Subscribe to view',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoGradientOverlay extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CreatorButton(
          avatarUrl: video.creatorAvatarUrl,
          onPressed: onCreatorPressed,
        ),
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
        _ActionButton(
          icon: isMuted ? Icons.volume_off_outlined : Icons.volume_up_outlined,
          label: '',
          onPressed: onSoundPressed,
        ),
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

    return Column(
      children: [
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
        ),
        Transform.translate(
          offset: const Offset(0, -7),
          child: Container(
            height: 24,
            width: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFFF2D95),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 15),
          ),
        ),
      ],
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

class _VideoCaption extends StatelessWidget {
  const _VideoCaption({required this.video});

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

class _VideoProgressBar extends StatelessWidget {
  const _VideoProgressBar({required this.controller});

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final activeController = controller;

    if (activeController == null || !activeController.value.isInitialized) {
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

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.videoId});

  final String videoId;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();
  late Future<List<VideoComment>> _commentsFuture;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _commentsFuture = AppServices.videoService.getComments(widget.videoId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final content = _controller.text.trim();

    if (content.isEmpty) {
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      await AppServices.videoService.addComment(
        videoId: widget.videoId,
        content: content,
      );

      _controller.clear();

      if (!mounted) {
        return;
      }

      setState(() {
        _commentsFuture = AppServices.videoService.getComments(widget.videoId);
      });
      Navigator.of(context).pop(true);
    } on ApiException catch (exception) {
      _showMessage('Comment failed (${exception.statusCode}): ${exception.message}');
    } catch (exception) {
      _showMessage('Comment failed: $exception');
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .72,
      maxChildSize: .94,
      minChildSize: .42,
      builder: (context, scrollController) {
        return Column(
          children: [
            SizedBox(
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FutureBuilder<List<VideoComment>>(
                    future: _commentsFuture,
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length;
                      return Text(
                        count == null ? 'Comments' : '$count Comments',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      );
                    },
                  ),
                  Positioned(
                    right: 8,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<List<VideoComment>>(
                future: _commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final comments = snapshot.data ?? const [];

                  if (comments.isEmpty) {
                    return const Center(child: Text('No comments yet.'));
                  }

                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final comment = comments[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_outline),
                        ),
                        title: Text(comment.content),
                        subtitle: Text(_relativeTime(comment.createdAtUtc)),
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  10,
                  14,
                  MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 17,
                      child: Icon(Icons.person_outline, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !_isPosting,
                        minLines: 1,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _isPosting ? null : _postComment,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _relativeTime(DateTime? value) {
    if (value == null) {
      return '';
    }

    final difference = DateTime.now().toUtc().difference(value.toUtc());

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    }

    if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    }

    if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }

    return 'Just now';
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report video'),
      content: TextField(
        controller: _controller,
        maxLines: 3,
        decoration: const InputDecoration(labelText: 'Reason'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class _VideoError extends StatelessWidget {
  const _VideoError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
