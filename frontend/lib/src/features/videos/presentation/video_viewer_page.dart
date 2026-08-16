import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../app/app_routes.dart';
import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/media_url.dart';
import '../models/video_comment.dart';
import '../models/video_detail.dart';

class VideoViewerPage extends StatefulWidget {
  const VideoViewerPage({
    required this.videoId,
    this.showBackButton = true,
    super.key,
  });

  final String videoId;
  final bool showBackButton;

  @override
  State<VideoViewerPage> createState() => _VideoViewerPageState();
}

class _VideoViewerPageState extends State<VideoViewerPage> {
  final _videoService = AppServices.videoService;

  late Future<VideoDetail> _videoFuture;
  VideoPlayerController? _controller;
  String? _loadedVideoUrl;
  DateTime? _openedAtUtc;
  bool _recordedView = false;
  bool _isLiked = false;
  int _likeCount = 0;
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    _videoFuture = _loadVideo();
  }

  @override
  void dispose() {
    _recordVideoView();
    _controller?.dispose();
    super.dispose();
  }

  Future<VideoDetail> _loadVideo() async {
    final video = await _videoService.getVideo(widget.videoId);

    _likeCount = video.likeCount;
    _commentCount = video.commentCount;
    _openedAtUtc = DateTime.now().toUtc();
    await _prepareController(video.videoUrl);

    return video;
  }

  void _recordVideoView() {
    if (_recordedView) {
      return;
    }

    final openedAtUtc = _openedAtUtc;

    if (openedAtUtc == null) {
      return;
    }

    _recordedView = true;

    final watchedSeconds = DateTime.now().toUtc().difference(openedAtUtc).inSeconds;
    final controller = _controller;
    final duration = controller?.value.duration.inSeconds ?? 0;
    final completionRate = duration <= 0 ? 0.0 : (watchedSeconds / duration).clamp(0.0, 1.0);

    unawaited(
      _videoService.recordVideoView(
        videoId: widget.videoId,
        watchDurationSeconds: watchedSeconds < 1 ? 1 : watchedSeconds,
        completionRate: completionRate,
      ).catchError((_) {}),
    );
  }

  Future<void> _prepareController(String videoUrl) async {
    final resolvedUrl = resolveMediaUrl(videoUrl);

    if (resolvedUrl.isEmpty || resolvedUrl == _loadedVideoUrl) {
      return;
    }

    final previousController = _controller;
    final controller = VideoPlayerController.networkUrl(Uri.parse(resolvedUrl));

    _loadedVideoUrl = resolvedUrl;
    _controller = controller;
    await previousController?.dispose();

    await controller.initialize();
    await controller.setLooping(true);
    await controller.play();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleLike() async {
    final nextLiked = !_isLiked;

    setState(() {
      _isLiked = nextLiked;
      _likeCount += nextLiked ? 1 : -1;
    });

    try {
      if (nextLiked) {
        await _videoService.likeVideo(widget.videoId);
      } else {
        await _videoService.unlikeVideo(widget.videoId);
      }
    } on ApiException catch (exception) {
      _showMessage('Like action failed (${exception.statusCode}): ${exception.message}');
      setState(() {
        _isLiked = !nextLiked;
        _likeCount += nextLiked ? -1 : 1;
      });
    } catch (exception) {
      _showMessage('Like action failed: $exception');
      setState(() {
        _isLiked = !nextLiked;
        _likeCount += nextLiked ? -1 : 1;
      });
    }
  }

  Future<void> _openComments() async {
    final addedComment = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return _CommentsSheet(videoId: widget.videoId);
      },
    );

    if (addedComment == true && mounted) {
      setState(() {
        _commentCount++;
      });
    }
  }

  Future<void> _reportVideo() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return const _ReportDialog();
      },
    );

    if (reason == null || reason.trim().isEmpty) {
      return;
    }

    try {
      await _videoService.reportVideo(
        videoId: widget.videoId,
        reason: reason.trim(),
      );

      _showMessage('Report submitted.');
    } on ApiException catch (exception) {
      _showMessage('Report failed (${exception.statusCode}): ${exception.message}');
    } catch (exception) {
      _showMessage('Report failed: $exception');
    }
  }

  void _showCreatorProfile(VideoDetail video) {
    Navigator.of(context).pushNamed(
      AppRoutes.userProfile,
      arguments: video.creatorId,
    );
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<VideoDetail>(
        future: _videoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _VideoError(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _videoFuture = _loadVideo();
                });
              },
            );
          }

          final video = snapshot.data;

          if (video == null) {
            return _VideoError(
              message: 'Video could not be loaded.',
              onRetry: () {
                setState(() {
                  _videoFuture = _loadVideo();
                });
              },
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              _VideoSurface(
                controller: _controller,
                thumbnailUrl: video.thumbnailUrl,
              ),
              _VideoGradientOverlay(),
              SafeArea(
                child: Stack(
                  children: [
                    if (widget.showBackButton)
                      Positioned(
                        left: 12,
                        top: 8,
                        child: IconButton.filledTonal(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ),
                    Positioned(
                      right: 14,
                      bottom: 72,
                      child: _SideActions(
                        video: video,
                        isLiked: _isLiked,
                        likeCount: _likeCount,
                        commentCount: _commentCount,
                        onCreatorPressed: () => _showCreatorProfile(video),
                        onLikePressed: _toggleLike,
                        onCommentsPressed: _openComments,
                        onReportPressed: _reportVideo,
                        onSoundPressed: () {
                          final controller = _controller;

                          if (controller == null) {
                            return;
                          }

                          controller.setVolume(controller.value.volume > 0 ? 0 : 1);
                          setState(() {});
                        },
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 88,
                      bottom: 80,
                      child: _VideoCaption(video: video),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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

class _SideActions extends StatelessWidget {
  const _SideActions({
    required this.video,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    required this.onCreatorPressed,
    required this.onLikePressed,
    required this.onCommentsPressed,
    required this.onReportPressed,
    required this.onSoundPressed,
  });

  final VideoDetail video;
  final bool isLiked;
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
          label: video.creatorName,
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
          icon: Icons.volume_up_outlined,
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
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkResponse(
          onTap: onPressed,
          radius: 28,
          child: const CircleAvatar(
            radius: 19,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF111827)),
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
        decoration: const InputDecoration(
          labelText: 'Reason',
        ),
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
  const _VideoError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
