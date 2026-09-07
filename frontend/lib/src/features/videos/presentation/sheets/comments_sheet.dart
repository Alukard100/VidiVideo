import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/dependency/app_services.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/media_url.dart';
import '../../../../shared/models/paged_result.dart';
import '../../../emojis/models/channel_emoji.dart';
import '../../models/video_comment.dart';
import 'report_content_dialog.dart';

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({
    required this.videoId,
    required this.onCommentAdded,
    super.key,
  });

  final String videoId;
  final VoidCallback onCommentAdded;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _controller = TextEditingController();

  final List<VideoComment> _comments = [];

  bool _isLoadingComments = false;
  bool _isLoadingMoreComments = false;
  bool _isPosting = false;

  int _commentPage = 1;
  int _commentTotalCount = 0;

  static const int _commentPageSize = 6;

  Future<PagedResult<ChannelEmoji>>? _availableEmojisFuture;

  bool _showEmojiPicker = false;

  int _emojiPage = 1;

  static const int _emojiPageSize = 16;

  @override
  void initState() {
    super.initState();

    _loadInitialComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Comments pagination
  // ---------------------------------------------------------------------------

  Future<void> _loadInitialComments() async {
    if (_isLoadingComments) {
      return;
    }

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final result = await AppServices.videoService.getComments(
        widget.videoId,
        page: 1,
        pageSize: _commentPageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _comments
          ..clear()
          ..addAll(result.items);

        _commentPage = result.page;
        _commentTotalCount = result.totalCount;
      });
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not load comments '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not load comments: $exception',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingComments = false;
        });
      }
    }
  }

  Future<void> _loadMoreComments() async {
    if (_isLoadingMoreComments ||
        _comments.length >= _commentTotalCount) {
      return;
    }

    setState(() {
      _isLoadingMoreComments = true;
    });

    try {
      final nextPage = _commentPage + 1;

      final result = await AppServices.videoService.getComments(
        widget.videoId,
        page: nextPage,
        pageSize: _commentPageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _comments.addAll(result.items);

        _commentPage = result.page;
        _commentTotalCount = result.totalCount;
      });
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not load more comments '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not load more comments: $exception',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMoreComments = false;
        });
      }
    }
  }

  bool get _hasMoreComments =>
      _comments.length < _commentTotalCount;

  // ---------------------------------------------------------------------------
  // Comment posting
  // ---------------------------------------------------------------------------

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

      // Refresh page 1 so the newest comment appears immediately.
      await _loadInitialComments();
    } on ApiException catch (exception) {
      if (exception.statusCode == 401 ||
          exception.statusCode == 403) {
        if (mounted) {
          Navigator.of(context).pushNamed(
            AppRoutes.register,
          );
        }

        return;
      }

      _showMessage(
        'Comment failed '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (exception) {
      _showMessage(
        'Comment failed: $exception',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Emoji picker
  // ---------------------------------------------------------------------------

  void _toggleEmojiPicker() {
    final token = AppServices.sessionStore.accessToken;

    if (token == null || token.isEmpty) {
      Navigator.of(context).pushNamed(
        AppRoutes.register,
      );

      return;
    }

    setState(() {
      _showEmojiPicker = !_showEmojiPicker;

      if (_showEmojiPicker &&
          _availableEmojisFuture == null) {
        _availableEmojisFuture = _loadAvailableEmojis();
      }
    });
  }

  Future<PagedResult<ChannelEmoji>> _loadAvailableEmojis() {
    return AppServices.emojiService.getAvailable(
      page: _emojiPage,
      pageSize: _emojiPageSize,
    );
  }

  void _changeEmojiPage(int nextPage) {
    if (nextPage < 1) {
      return;
    }

    setState(() {
      _emojiPage = nextPage;
      _availableEmojisFuture = _loadAvailableEmojis();
    });
  }

  void _insertEmoji(ChannelEmoji emoji) {
    final shortcode = ':${emoji.code}:';

    final text = _controller.text;
    final selection = _controller.selection;

    var start = selection.start;
    var end = selection.end;

    if (start < 0 || end < 0) {
      start = text.length;
      end = text.length;
    }

    final newText = text.replaceRange(
      start,
      end,
      shortcode,
    );

    final cursorPosition =
        start + shortcode.length;

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: cursorPosition,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

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
            _buildHeader(),

            const Divider(height: 1),

            Expanded(
              child: _buildComments(
                scrollController,
              ),
            ),

            if (_showEmojiPicker)
              _buildEmojiPicker(),

            _buildCommentInput(),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        6,
        8,
        6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _isLoadingComments &&
                      _comments.isEmpty
                  ? 'Comments'
                  : '$_commentTotalCount Comments',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
            ),
            tooltip: 'Close comments',
          ),
        ],
      ),
    );
  }

  Widget _buildComments(
    ScrollController scrollController,
  ) {
    if (_isLoadingComments &&
        _comments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_comments.isEmpty) {
      return const Center(
        child: Text(
          'No comments yet.',
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(16),

      // +1 item za Load more sekciju.
      itemCount:
          _comments.length +
          (_hasMoreComments ? 1 : 0),

      separatorBuilder: (context, index) {
        return const SizedBox(height: 10);
      },

      itemBuilder: (context, index) {
        if (index >= _comments.length) {
          return _buildLoadMore();
        }

        final comment = _comments[index];

        return _buildComment(comment);
      },
    );
  }

  Widget _buildComment(
    VideoComment comment,
  ) {
    final avatarUrl = resolveMediaUrl(
      comment.authorAvatarUrl,
    );

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
        backgroundImage:
            avatarUrl.isEmpty
                ? null
                : NetworkImage(
                    avatarUrl,
                  ),
        child:
            avatarUrl.isEmpty
                ? const Icon(
                    Icons.person_outline,
                  )
                : null,
      ),

      title: Text(
        comment.authorDisplayName.isEmpty
            ? 'User'
            : comment.authorDisplayName,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),

      subtitle: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _CommentContent(
            comment: comment,
          ),

          const SizedBox(height: 2),

          Text(
            _relativeTime(
              comment.createdAtUtc,
            ),
          ),
        ],
      ),

      trailing: IconButton(
        tooltip: 'Report comment',
        icon: const Icon(
          Icons.flag_outlined,
          size: 18,
        ),
        color: Colors.grey,
        onPressed: () {
          _reportComment(comment);
        },
      ),
    );
  }

  Widget _buildLoadMore() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Center(
        child: TextButton.icon(
          onPressed:
              _isLoadingMoreComments
                  ? null
                  : _loadMoreComments,

          icon:
              _isLoadingMoreComments
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.expand_more,
                    ),

          label: Text(
            _isLoadingMoreComments
                ? 'Loading...'
                : 'Load more comments',
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Emoji picker UI
  // ---------------------------------------------------------------------------

  Widget _buildEmojiPicker() {
    final future = _availableEmojisFuture;

    if (future == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.black12,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        10,
      ),
      child: FutureBuilder<
          PagedResult<ChannelEmoji>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const SizedBox(
              height: 100,
              child: Center(
                child:
                    CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return SizedBox(
              height: 100,
              child: Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _availableEmojisFuture =
                          _loadAvailableEmojis();
                    });
                  },
                  child: Text(
                    '${snapshot.error}',
                  ),
                ),
              ),
            );
          }

          final result = snapshot.data;

          if (result == null) {
            return const SizedBox.shrink();
          }

          final emojis = result.items;

          final totalPages =
              result.pageSize <= 0
                  ? 1
                  : (result.totalCount /
                          result.pageSize)
                      .ceil();

          final hasPrevious =
              result.page > 1;

          final hasNext =
              result.page < totalPages;

          if (emojis.isEmpty) {
            return const SizedBox(
              height: 82,
              child: Center(
                child: Text(
                  'No emojis available.',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Available emojis',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    'Page ${result.page} / '
                    '${totalPages < 1 ? 1 : totalPages}',
                    style: const TextStyle(
                      color: Colors.black45,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: 76,
                child: ListView.separated(
                  scrollDirection:
                      Axis.horizontal,
                  itemCount: emojis.length,
                  separatorBuilder:
                      (_, _) =>
                          const SizedBox(
                    width: 8,
                  ),
                  itemBuilder:
                      (context, index) {
                    final emoji =
                        emojis[index];

                    return _EmojiPickerItem(
                      emoji: emoji,
                      onPressed: () {
                        _insertEmoji(emoji);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 4),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip:
                        'Previous emojis',
                    onPressed:
                        hasPrevious
                            ? () {
                                _changeEmojiPage(
                                  result.page -
                                      1,
                                );
                              }
                            : null,
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                    ),
                  ),

                  IconButton(
                    tooltip: 'Next emojis',
                    onPressed:
                        hasNext
                            ? () {
                                _changeEmojiPage(
                                  result.page +
                                      1,
                                );
                              }
                            : null,
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCommentInput() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          14,
          10,
          14,
          MediaQuery.of(context)
                  .viewInsets
                  .bottom +
              12,
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 17,
              child: Icon(
                Icons.person_outline,
                size: 18,
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              tooltip: 'Emojis',
              onPressed:
                  _isPosting
                      ? null
                      : _toggleEmojiPicker,
              icon: Icon(
                _showEmojiPicker
                    ? Icons.emoji_emotions
                    : Icons
                        .emoji_emotions_outlined,
              ),
            ),

            const SizedBox(width: 4),

            Expanded(
              child: TextField(
                controller: _controller,
                enabled: !_isPosting,
                minLines: 1,
                maxLines: 3,
                decoration:
                    const InputDecoration(
                  hintText:
                      'Add a comment...',
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(width: 8),

            IconButton.filled(
              onPressed:
                  _isPosting
                      ? null
                      : _postComment,
              icon: const Icon(
                Icons.send,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  String _relativeTime(DateTime? value) {
    if (value == null) {
      return '';
    }

    final difference =
        DateTime.now()
            .toUtc()
            .difference(value.toUtc());

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
    final reason =
        await showDialog<String>(
      context: context,
      builder: (_) =>
          const ReportContentDialog(
        title: 'Report comment',
      ),
    );

    if (!mounted) {
      return;
    }

    if (reason == null ||
        reason.trim().isEmpty) {
      return;
    }

    try {
      await AppServices.videoService
          .reportComment(
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

class _EmojiPickerItem extends StatelessWidget {
  const _EmojiPickerItem({
    required this.emoji,
    required this.onPressed,
  });

  final ChannelEmoji emoji;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        resolveMediaUrl(
      emoji.imageUrl,
    );

    return InkWell(
      onTap: onPressed,
      borderRadius:
          BorderRadius.circular(12),
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              padding:
                  const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color:
                    Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                border: Border.all(
                  color: Colors.black12,
                ),
              ),
              child:
                  imageUrl.isEmpty
                      ? const Icon(
                          Icons
                              .emoji_emotions_outlined,
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons
                                  .broken_image_outlined,
                            );
                          },
                        ),
            ),

            const SizedBox(height: 3),

            Text(
              ':${emoji.code}:',
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentContent extends StatelessWidget {
  const _CommentContent({
    required this.comment,
  });

  final VideoComment comment;

  @override
  Widget build(BuildContext context) {
    if (comment.emojis.isEmpty) {
      return Text(comment.content);
    }

    final emojiLookup = {
      for (final emoji in comment.emojis)
        emoji.code.toLowerCase():
            emoji.imageUrl,
    };

    final regex = RegExp(
      r':([A-Za-z0-9_]{1,32}):',
    );

    final spans = <InlineSpan>[];

    var currentIndex = 0;

    for (final match
        in regex.allMatches(
      comment.content,
    )) {
      if (match.start >
          currentIndex) {
        spans.add(
          TextSpan(
            text: comment.content.substring(
              currentIndex,
              match.start,
            ),
          ),
        );
      }

      final code = match.group(1);

      final imageUrl =
          code == null
              ? null
              : emojiLookup[
                  code.toLowerCase()];

      if (imageUrl == null ||
          imageUrl.isEmpty) {
        spans.add(
          TextSpan(
            text: match.group(0),
          ),
        );
      } else {
        final resolvedUrl =
            resolveMediaUrl(imageUrl);

        spans.add(
          WidgetSpan(
            alignment:
                PlaceholderAlignment.middle,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 2,
              ),
              child: Image.network(
                resolvedUrl,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                errorBuilder:
                    (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Text(
                    match.group(0) ?? '',
                  );
                },
              ),
            ),
          ),
        );
      }

      currentIndex = match.end;
    }

    if (currentIndex <
        comment.content.length) {
      spans.add(
        TextSpan(
          text: comment.content.substring(
            currentIndex,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style:
            DefaultTextStyle.of(context)
                .style,
        children: spans,
      ),
    );
  }
}