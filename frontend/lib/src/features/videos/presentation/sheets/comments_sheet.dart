import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/dependency/app_services.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/media_url.dart';
import '../../models/video_comment.dart';
import 'report_content_dialog.dart';

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({
    required this.videoId, 
    required this.onCommentAdded,
    super.key
    });

  final String videoId;
  final VoidCallback onCommentAdded;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}



class _CommentsSheetState extends State<CommentsSheet> {
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

      widget.onCommentAdded();

      setState(() {
        _commentsFuture = AppServices.videoService.getComments(widget.videoId);
      });
    } on ApiException catch (exception) {
      if (exception.statusCode == 401 || exception.statusCode == 403) {
        Navigator.of(context).pushNamed(AppRoutes.register);
        return;
      }

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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: FutureBuilder<List<VideoComment>>(
                      future: _commentsFuture,
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length;

                        return Text(
                          count == null
                              ? 'Comments'
                              : '$count Comments',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                  ),

                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                    ),
                    tooltip: 'Close comments',
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
                      final avatarUrl = resolveMediaUrl(comment.authorAvatarUrl);

                      if (avatarUrl.isNotEmpty && mounted) {
                        unawaited(
                          precacheImage(
                            NetworkImage(avatarUrl),
                            context,
                          ),
                        );
                      }

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundImage: avatarUrl.isEmpty ? null : NetworkImage(avatarUrl),
                          child: avatarUrl.isEmpty
                              ? const Icon(Icons.person_outline)
                              : null,
                        ),
                        title: Text(
                          comment.authorDisplayName.isEmpty
                              ? 'User'
                              : comment.authorDisplayName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment.content),
                            const SizedBox(height: 2),
                            Text(_relativeTime(comment.createdAtUtc)),
                          ],
                        ),
                        trailing: IconButton(
                          tooltip: 'Report comment',
                          icon: const Icon(
                            Icons.flag_outlined,
                            size: 18,
                          ),
                          color: Colors.grey,
                          onPressed: () =>
                            _reportComment(comment),
                        ),
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

  Future<void> _reportComment(
    VideoComment comment,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const ReportContentDialog(
        title: 'Report comment',
      ),
    );

    if (!mounted) {
      return;
    }

    if (reason == null || reason.trim().isEmpty) {
      return;
    }

    try {
      await AppServices.videoService.reportComment(
        commentId: comment.id,
        reason: reason.trim(),
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Comment reported successfully.',
      );
    } on ApiException catch (exception) {
      if (exception.statusCode == 401 ||
          exception.statusCode == 403) {
        Navigator.of(context).pushNamed(
          AppRoutes.register,
        );
        return;
      }

      _showMessage(
        'Report failed '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (exception) {
      _showMessage(
        'Report failed: $exception',
      );
    }
  }

}
