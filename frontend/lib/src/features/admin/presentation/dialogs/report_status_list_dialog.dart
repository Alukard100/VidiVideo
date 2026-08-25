import 'package:flutter/material.dart';

import '../../../../core/dependency/app_services.dart';
import '../../../../core/network/api_client.dart';
import '../../models/content_report_history_item.dart';

class ReportStatusListDialog extends StatefulWidget {
  const ReportStatusListDialog({
    required this.status,
    required this.title,
    super.key,
  });

  final int status;
  final String title;

  @override
  State<ReportStatusListDialog> createState() =>
      _ReportStatusListDialogState();
}

class _ReportStatusListDialogState
    extends State<ReportStatusListDialog> {
  final _service = AppServices.contentReportService;

  static const int _pageSize = 10;

  bool _isLoading = true;
  String? _error;

  List<ContentReportHistoryItem> _items = [];

  int _page = 1;
  int _totalCount = 0;

  int get _totalPages {
    if (_totalCount == 0) {
      return 1;
    }

    return (_totalCount / _pageSize).ceil();
  }

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _service.getByStatus(
        status: widget.status,
        page: _page,
        pageSize: _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _items = result.items;
        _totalCount = result.totalCount;
      });
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            'Unable to load reports (${exception.statusCode}): '
            '${exception.message}';
      });
    } catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'Unable to load reports.';
      });

      debugPrint(
        'REPORT STATUS LIST ERROR: $exception',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _previousPage() async {
    if (_page <= 1 || _isLoading) {
      return;
    }

    setState(() {
      _page--;
    });

    await _loadReports();
  }

  Future<void> _nextPage() async {
    if (_page >= _totalPages || _isLoading) {
      return;
    }

    setState(() {
      _page++;
    });

    await _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 900,
          maxHeight: 680,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(
              child: _buildBody(),
            ),
            const Divider(height: 1),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        20,
        16,
        20,
      ),
      child: Row(
        children: [
          _statusIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$_totalCount ${_totalCount == 1 ? 'report' : 'reports'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.close_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 42,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loadReports,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _emptyIcon(),
                size: 46,
                color: const Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 12),
              const Text(
                'No reports found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'There are currently no '
                '${widget.title.toLowerCase()}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildTableHeader(),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: _items.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildReportRow(
                _items[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'REPORT REASON',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
                letterSpacing: .5,
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            flex: 4,
            child: Text(
              'RESOLUTION NOTE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
                letterSpacing: .5,
              ),
            ),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 130,
            child: Text(
              'DATE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
                letterSpacing: .5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(
    ContentReportHistoryItem item,
  ) {
    final resolutionNote =
        item.resolutionNote?.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              item.reason.isEmpty
                  ? 'No reason provided.'
                  : item.reason,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF111827),
                height: 1.35,
              ),
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            flex: 4,
            child: Text(
              resolutionNote == null ||
                      resolutionNote.isEmpty
                  ? _resolutionFallback()
                  : resolutionNote,
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: resolutionNote == null ||
                        resolutionNote.isEmpty
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF374151),
                fontStyle:
                    resolutionNote == null ||
                            resolutionNote.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
              ),
            ),
          ),

          const SizedBox(width: 20),

          SizedBox(
            width: 130,
            child: Text(
              _formatDate(
                item.reviewedAtUtc ??
                    item.createdAtUtc,
              ),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      child: Row(
        children: [
          Text(
            _totalCount == 0
                ? 'No results'
                : 'Showing '
                    '${((_page - 1) * _pageSize) + 1}'
                    '–'
                    '${_lastVisibleItem()} '
                    'of $_totalCount',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),

          const Spacer(),

          OutlinedButton(
            onPressed:
                _page > 1 && !_isLoading
                    ? _previousPage
                    : null,
            child: const Text('Previous'),
          ),

          const SizedBox(width: 12),

          Text(
            'Page $_page of $_totalPages',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),

          const SizedBox(width: 12),

          OutlinedButton(
            onPressed:
                _page < _totalPages &&
                        !_isLoading
                    ? _nextPage
                    : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  int _lastVisibleItem() {
    final last = _page * _pageSize;

    if (last > _totalCount) {
      return _totalCount;
    }

    return last;
  }

  String _resolutionFallback() {
    if (widget.status == 1) {
      return 'Awaiting review';
    }

    return 'No resolution note';
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '—';
    }

    final local = date.toLocal();

    final day =
        local.day.toString().padLeft(2, '0');
    final month =
        local.month.toString().padLeft(2, '0');

    return '$day.$month.${local.year}';
  }

  Widget _statusIcon() {
    switch (widget.status) {
      case 1:
        return const Icon(
          Icons.schedule_rounded,
          color: Color(0xFFF59E0B),
          size: 28,
        );

      case 2:
        return const Icon(
          Icons.check_circle_outline_rounded,
          color: Color(0xFF16A34A),
          size: 28,
        );

      case 3:
        return const Icon(
          Icons.cancel_outlined,
          color: Color(0xFFDC2626),
          size: 28,
        );

      default:
        return const Icon(
          Icons.flag_outlined,
          color: Color(0xFF6B7280),
          size: 28,
        );
    }
  }

  IconData _emptyIcon() {
    switch (widget.status) {
      case 1:
        return Icons.schedule_rounded;
      case 2:
        return Icons.check_circle_outline;
      case 3:
        return Icons.cancel_outlined;
      default:
        return Icons.flag_outlined;
    }
  }
}