import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/dependency/app_services.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/media_url.dart';
import '../../models/content_report_detail.dart';
import '../../models/content_report_summary.dart';

class ReviewContentReportDialog extends StatefulWidget {
  const ReviewContentReportDialog({
    required this.report,
    super.key,
  });

  final ContentReportSummary report;

  @override
  State<ReviewContentReportDialog> createState() =>
      _ReviewContentReportDialogState();
}

class _ReviewContentReportDialogState
    extends State<ReviewContentReportDialog> {
  final _resolutionController =
      TextEditingController();

  late Future<ContentReportDetail> _detailFuture;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _detailFuture =
        AppServices.contentReportService.getDetail(
      contentId: widget.report.contentId,
      contentType: widget.report.contentType,
    );
  }

  @override
  void dispose() {
    _resolutionController.dispose();
    super.dispose();
  }

  Future<void> _review(int status) async {
    final note =
        _resolutionController.text.trim();

    if (note.isEmpty) {
      _showMessage(
        'Please enter a resolution note.',
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AppServices.contentReportService.review(
        contentId: widget.report.contentId,
        contentType: widget.report.contentType,
        resolutionNote: note,
        status: status,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ApiException catch (exception) {
      _showMessage(
        'Review failed '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (_) {
      _showMessage(
        'Unable to review this content.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _removeContent(
    ContentReportDetail detail,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Remove ${detail.contentType.toLowerCase()}?',
          ),
          content: Text(
            detail.contentType.toLowerCase() ==
                    'video'
                ? 'This video will no longer be visible to members.'
                : 'This comment will no longer be visible to members.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext)
                      .pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext)
                      .pop(true),
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFFDC2626),
              ),
              child:
                  const Text('Remove content'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AppServices.contentReportService
          .removeContent(
        contentId: detail.contentId,
        contentType: detail.contentType,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ApiException catch (exception) {
      _showMessage(
        'Unable to remove content '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (exception) {
      debugPrint(
        'REMOVE CONTENT ERROR: $exception',
      );

      _showMessage(
        'Unable to remove content.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 760,
          maxHeight: 760,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Expanded(
              child:
                  FutureBuilder<ContentReportDetail>(
                future: _detailFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError ||
                      snapshot.data == null) {
                    return Center(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 42,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage(
                                snapshot.error,
                              ),
                              textAlign:
                                  TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _detailFuture =
                                      AppServices
                                          .contentReportService
                                          .getDetail(
                                    contentId:
                                        widget.report
                                            .contentId,
                                    contentType:
                                        widget.report
                                            .contentType,
                                  );
                                });
                              },
                              icon: const Icon(
                                Icons.refresh,
                              ),
                              label:
                                  const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return _buildContent(
                    snapshot.data!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(24, 18, 12, 18),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFEEF2FF),
              borderRadius:
                  BorderRadius.circular(10),
            ),
            child: Icon(
              widget.report.contentType
                          .toLowerCase() ==
                      'video'
                  ? Icons.video_library_outlined
                  : Icons.comment_outlined,
              color: const Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Review Reported Content',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.report.contentType} • '
                  '${widget.report.reportCount} '
                  '${widget.report.reportCount == 1 ? 'report' : 'reports'}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isSubmitting
                ? null
                : () =>
                    Navigator.of(context).pop(false),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    ContentReportDetail detail,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Reported content',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          _ModerationContentPreview(
            detail: detail,
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              const Text(
                'Reports',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  '${detail.reports.length}',
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight:
                        FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (detail.reports.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 24,
              ),
              child: Center(
                child: Text(
                  'No reports available.',
                ),
              ),
            )
          else
            ...detail.reports.map(
              (report) => Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 10,
                ),
                padding:
                    const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(10),
                  border: Border.all(
                    color:
                        const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 15,
                          child: Icon(
                            Icons.person_outline,
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            report.reporterName
                                    .isEmpty
                                ? 'User'
                                : report
                                    .reporterName,
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(
                            report.createdAtUtc,
                          ),
                          style:
                              const TextStyle(
                            color:
                                Color(0xFF9CA3AF),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(report.reason),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 18),

          TextField(
            controller:
                _resolutionController,
            enabled: !_isSubmitting,
            maxLines: 3,
            maxLength: 500,
            decoration:
                const InputDecoration(
              labelText: 'Resolution note',
              hintText:
                  'Enter moderation decision notes...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              FilledButton.icon(
                onPressed: _isSubmitting || detail.isDeleted
                    ? null
                    : () => _removeContent(detail),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(
                  Icons.delete_outline,
                ),
                label: Text(
                  detail.isDeleted
                    ? 'Content Removed'
                    : 'Remove ${detail.contentType}',
                ),
              ),

              const Spacer(),

              OutlinedButton(
                onPressed: _isSubmitting
                    ? null
                    : () =>
                        Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),

              const SizedBox(width: 10),

              OutlinedButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () => _review(3),
                icon: const Icon(
                  Icons.close_rounded,
                ),
                label: const Text(
                  'Reject Reports',
                ),
              ),

              const SizedBox(width: 10),

              FilledButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () => _review(2),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.check_rounded,
                      ),
                label: const Text(
                  'Resolve',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _errorMessage(Object? error) {
    if (error is ApiException) {
      return 'Unable to load report '
          '(${error.statusCode}): '
          '${error.message}';
    }

    return 'Unable to load report.';
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '';
    }

    final local = value.toLocal();

    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

class _ModerationContentPreview extends StatefulWidget {
  const _ModerationContentPreview({
    required this.detail,
  });

  final ContentReportDetail detail;

  @override
  State<_ModerationContentPreview> createState() =>
      _ModerationContentPreviewState();
}

class _ModerationContentPreviewState
    extends State<_ModerationContentPreview> {
  VideoPlayerController? _controller;

  bool _isLoading = false;
  String? _error;

  bool get _isVideo =>
      widget.detail.contentType.toLowerCase() == 'video';

  @override
  void initState() {
    super.initState();

    if (_isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    final streamUrl =
        widget.detail.videoStreamUrl?.trim() ?? '';

    if (streamUrl.isEmpty) {
      setState(() {
        _error = 'Video stream is not available.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final resolvedUrl =
          resolveMediaUrl(streamUrl);

      final token =
          AppServices.sessionStore.accessToken;

      final controller =
          VideoPlayerController.networkUrl(
        Uri.parse(resolvedUrl),
        httpHeaders: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      );

      await controller.initialize();

      await controller.setLooping(true);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
      });
    } catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            'Unable to load video preview.';
      });

      debugPrint(
        'MODERATION VIDEO ERROR: $exception',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized) {
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

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVideo) {
      return _buildCommentPreview();
    }

    return _buildVideoPreview();
  }

  Widget _buildCommentPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.comment_outlined,
                size: 18,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              const Text(
                'Comment',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                widget.detail.creatorName,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),

          if (widget.detail.isDeleted) ...[
            const SizedBox(height: 12),
            _RemovedContentNotice(),
          ],
          const SizedBox(height: 14),
          Text(
            widget.detail.contentPreview.isEmpty
                ? 'No comment content available.'
                : widget.detail.contentPreview,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildVideoPreview() {
    final controller = _controller;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.video_library_outlined,
                size: 18,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              const Text(
                'Video',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                widget.detail.creatorName,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          if (widget.detail.isDeleted) ...[
            const SizedBox(height: 12),
            const _RemovedContentNotice(),
          ],

          const SizedBox(height: 14),

          if (_isLoading)
            const SizedBox(
              height: 280,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            )
          else if (controller != null &&
              controller.value.isInitialized)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 360,
                  maxWidth: 620,
                ),
                child: AspectRatio(
                  aspectRatio:
                      controller.value.aspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      VideoPlayer(controller),

                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _togglePlayback,
                        child: Center(
                          child: controller.value.isPlaying
                              ? const SizedBox.shrink()
                              : IconButton.filled(
                                  onPressed: _togglePlayback,
                                  iconSize: 34,
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                  ),
                                ),
                        ),
                      ),

                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child:
                            VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                          padding:
                              EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 14),

          Text(
            widget.detail.contentPreview.isEmpty
                ? 'No caption.'
                : widget.detail.contentPreview,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _RemovedContentNotice extends StatelessWidget {
  const _RemovedContentNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFCA5A5),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.delete_outline,
            size: 18,
            color: Color(0xFFDC2626),
          ),
          SizedBox(width: 8),
          Text(
            'This content has already been removed.',
            style: TextStyle(
              color: Color(0xFFB91C1C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}