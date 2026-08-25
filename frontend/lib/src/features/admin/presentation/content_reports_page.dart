import 'package:flutter/material.dart';
import 'package:vidivideo_app/src/features/admin/presentation/dialogs/report_status_list_dialog.dart';

import '../../../app/app_routes.dart';
import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/paged_result.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import '../models/content_report_stats.dart';
import '../models/content_report_summary.dart';
import 'admin_navigation.dart';
import 'dialogs/review_content_report_dialog.dart';
import 'widgets/admin_profile_menu.dart';

enum _ReportStatusFilter {
  all,
  pending,
  resolved,
  rejected,
}

extension on _ReportStatusFilter {
  int? get apiValue {
    switch (this) {
      case _ReportStatusFilter.all:
        return null;

      case _ReportStatusFilter.pending:
        return 1;

      case _ReportStatusFilter.resolved:
        return 2;

      case _ReportStatusFilter.rejected:
        return 3;
    }
  }

  String get label {
    switch (this) {
      case _ReportStatusFilter.all:
        return 'All Status';

      case _ReportStatusFilter.pending:
        return 'Pending';

      case _ReportStatusFilter.resolved:
        return 'Resolved';

      case _ReportStatusFilter.rejected:
        return 'Rejected';
    }
  }
}

class ContentReportsPage extends StatefulWidget {
  const ContentReportsPage({
    super.key,
  });

  @override
  State<ContentReportsPage> createState() =>
      _ContentReportsPageState();
}

class _ContentReportsPageState
    extends State<ContentReportsPage> {
  PagedResult<ContentReportSummary>? _result;
  ContentReportStats? _stats;

  _ReportStatusFilter _statusFilter =
      _ReportStatusFilter.all;

  bool _isLoading = false;
  bool _isLoadingStats = false;

  Object? _error;

  int _page = 1;

  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();

    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadReports(),
      _loadStats(),
    ]);
  }

  Future<void> _openStatusReports({
    required int status,
    required String title,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (_) => ReportStatusListDialog(
        status: status,
        title: title,
      ),
    );
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result =
          await AppServices
              .contentReportService
              .getReports(
        status: _statusFilter.apiValue,
        page: _page,
        pageSize: _pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _result = result;
      });
    } catch (exception) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = exception;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final stats =
          await AppServices
              .contentReportService
              .getStats();

      if (!mounted) {
        return;
      }

      setState(() {
        _stats = stats;
      });
    } catch (_) {
      // Stats should not prevent the report table
      // from loading.
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    await _loadAll();
  }

  Future<void> _openReview(
    ContentReportSummary report,
  ) async {
    final reviewed =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          ReviewContentReportDialog(
        report: report,
      ),
    );

    if (reviewed == true) {
      await _refresh();
    }
  }

  int get _totalPages {
    final total =
        _result?.totalCount ?? 0;

    if (total <= 0) {
      return 1;
    }

    return (total / _pageSize).ceil();
  }

  Future<void> _previousPage() async {
    if (_page <= 1) {
      return;
    }

    setState(() {
      _page--;
    });

    await _loadReports();
  }

  Future<void> _nextPage() async {
    if (_page >= _totalPages) {
      return;
    }

    setState(() {
      _page++;
    });

    await _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Reported Content',
      navigationItems:
          adminNavigationItems(
        AppRoutes.adminReports,
      ),
      navigationFooter: const AdminProfileMenu(),

      body: Container(
        color: const Color(0xFFF8F9FB),
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding:
                const EdgeInsets.all(24),
            children: [
              _buildPageHeader(),

              const SizedBox(height: 20),

              _buildStats(),

              const SizedBox(height: 20),

              _buildReportsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return const Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Reported Content',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Review and resolve content reported by members.',
          style: TextStyle(
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final stats = _stats;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 800
                ? 3
                : 1;

        final cards = [
          _StatCard(
            title: 'Pending Reports',
            value: stats?.pending ?? 0,
            icon:
                Icons.warning_amber_rounded,
            iconColor:
                const Color(0xFFF59E0B),
            backgroundColor:
                const Color(0xFFFFFBEB),
            onTap: () => _openStatusReports(
              status: 1,
              title: 'Pending Reports'
            )
                
          ),
          _StatCard(
            title: 'Resolved',
            value: stats?.resolved ?? 0,
            icon:
                Icons.check_circle_outline,
            iconColor:
                const Color(0xFF16A34A),
            backgroundColor:
                const Color(0xFFF0FDF4),
            onTap: () => _openStatusReports(
              status: 2,
              title: 'Resolved Reports'
            )
          ),
          _StatCard(
            title: 'Rejected',
            value: stats?.rejected ?? 0,
            icon: Icons
                .cancel_outlined,
            iconColor:
                const Color(0xFFDC2626),
            backgroundColor:
                const Color(0xFFFEF2F2),
            onTap: () => _openStatusReports(
              status: 3,
              title: 'Rejected Reports'
            )
          ),
        ];

        if (_isLoadingStats &&
            stats == null) {
          return const SizedBox(
            height: 120,
            child: Center(
              child:
                  CircularProgressIndicator(),
            ),
          );
        }

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio:
              columns == 3 ? 2.6 : 4,
          children: cards,
        );
      },
    );
  }

  Widget _buildReportsCard() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            _buildToolbar(),

            if (_isLoading &&
                _result != null) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],

            const SizedBox(height: 16),

            _buildTable(),

            const SizedBox(height: 16),

            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'All Reports',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),

        SizedBox(
          width: 170,
          child:
              DropdownButtonFormField<
                  _ReportStatusFilter>(
            initialValue:
                _statusFilter,
            decoration:
                const InputDecoration(
              labelText: 'Status',
              isDense: true,
              border:
                  OutlineInputBorder(),
            ),
            items: [
              for (final status
                  in _ReportStatusFilter
                      .values)
                DropdownMenuItem(
                  value: status,
                  child:
                      Text(status.label),
                ),
            ],
            onChanged: _isLoading
                ? null
                : (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _statusFilter =
                          value;
                      _page = 1;
                    });

                    _loadReports();
                  },
          ),
        ),

        const SizedBox(width: 10),

        IconButton.filledTonal(
          onPressed:
              _isLoading ? null : _refresh,
          tooltip: 'Refresh',
          icon:
              const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildTable() {
    if (_isLoading &&
        _result == null) {
      return const SizedBox(
        height: 250,
        child: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null &&
        _result == null) {
      return SizedBox(
        height: 250,
        child: Center(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 42,
                color:
                    Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage(_error!),
                textAlign:
                    TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _loadReports,
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

    final reports =
        _result?.items ??
            const <ContentReportSummary>[];

    if (reports.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Icon(
                Icons
                    .flag_outlined,
                size: 44,
                color:
                    Color(0xFF9CA3AF),
              ),
              SizedBox(height: 12),
              Text(
                'No reports found.',
                style: TextStyle(
                  color:
                      Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection:
              Axis.horizontal,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(
              minWidth:
                  constraints.maxWidth,
            ),
            child: DataTable(
              headingRowColor:
                  WidgetStatePropertyAll(
                const Color(
                  0xFFF9FAFB,
                ),
              ),
              dataRowMinHeight: 62,
              dataRowMaxHeight: 74,
              columnSpacing: 28,
              columns: const [
                DataColumn(
                  label:
                      Text('Content'),
                ),
                DataColumn(
                  label:
                      Text('Creator'),
                ),
                DataColumn(
                  label:
                      Text('Reports'),
                  numeric: true,
                ),
                DataColumn(
                  label:
                      Text('Status'),
                ),
                DataColumn(
                  label:
                      Text('Last Reported'),
                ),
                DataColumn(
                  label:
                      Text('Actions'),
                ),
              ],
              rows: [
                for (final report
                    in reports)
                  _buildRow(report),
              ],
            ),
          ),
        );
      },
    );
  }

  DataRow _buildRow(
    ContentReportSummary report,
  ) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 280,
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration:
                      BoxDecoration(
                    color: report
                                .contentType
                                .toLowerCase() ==
                            'video'
                        ? const Color(
                            0xFFEEF2FF,
                          )
                        : const Color(
                            0xFFF0FDF4,
                          ),
                    borderRadius:
                        BorderRadius
                            .circular(8),
                  ),
                  child: Icon(
                    report.contentType
                                .toLowerCase() ==
                            'video'
                        ? Icons
                            .video_library_outlined
                        : Icons
                            .comment_outlined,
                    size: 19,
                    color: report
                                .contentType
                                .toLowerCase() ==
                            'video'
                        ? const Color(
                            0xFF4F46E5,
                          )
                        : const Color(
                            0xFF16A34A,
                          ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        report
                                .contentPreview
                                .isEmpty
                            ? report
                                .contentType
                            : report
                                .contentPreview,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        report
                            .contentType,
                        style:
                            const TextStyle(
                          fontSize: 11,
                          color: Color(
                            0xFF6B7280,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        DataCell(
          Text(
            report.creatorName,
          ),
        ),

        DataCell(
          Align(
            alignment:
                Alignment.centerRight,
            child: Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 9,
                vertical: 4,
              ),
              decoration:
                  BoxDecoration(
                color: report
                            .reportCount >
                        1
                    ? const Color(
                        0xFFFEE2E2,
                      )
                    : const Color(
                        0xFFF3F4F6,
                      ),
                borderRadius:
                    BorderRadius
                        .circular(20),
              ),
              child: Text(
                report.reportCount
                    .toString(),
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ),
        ),

        DataCell(
          _statusBadge(
            report.status,
          ),
        ),

        DataCell(
          Text(
            _formatDate(
              report
                  .lastReportedAtUtc,
            ),
          ),
        ),

        DataCell(
          OutlinedButton(
            onPressed: () =>
                _openReview(report),
            child: const Text(
              'Review',
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(int status) {
    late final String label;
    late final Color foreground;
    late final Color background;

    switch (status) {
      case 2:
        label = 'Resolved';
        foreground =
            const Color(0xFF15803D);
        background =
            const Color(0xFFF0FDF4);
        break;

      case 3:
        label = 'Rejected';
        foreground =
            const Color(0xFFB91C1C);
        background =
            const Color(0xFFFEF2F2);
        break;

      case 1:
      default:
        label = 'Pending';
        foreground =
            const Color(0xFFD97706);
        background =
            const Color(0xFFFFFBEB);
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: foreground
              .withValues(alpha: .25),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPagination() {
    final total =
        _result?.totalCount ?? 0;

    return Row(
      children: [
        Text(
          '$total reported '
          '${total == 1 ? 'content item' : 'content items'}',
          style: const TextStyle(
            color:
                Color(0xFF6B7280),
            fontSize: 13,
          ),
        ),

        const Spacer(),

        OutlinedButton(
          onPressed:
              _page > 1 && !_isLoading
                  ? _previousPage
                  : null,
          child:
              const Text('Previous'),
        ),

        const SizedBox(width: 12),

        Text(
          'Page $_page of $_totalPages',
          style: const TextStyle(
            fontWeight:
                FontWeight.w500,
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
    );
  }

  String _errorMessage(
    Object error,
  ) {
    if (error is ApiException) {
      return 'Unable to load reports '
          '(${error.statusCode}): '
          '${error.message}';
    }

    return 'Unable to load reports.';
  }

  String _formatDate(
    DateTime? value,
  ) {
    if (value == null) {
      return '-';
    }

    final local =
        value.toLocal();

    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.'
        '${local.year}';
  }
}

class _StatCard
    extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
Widget build(BuildContext context) {
  return Card(
    elevation: 0,
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(
        color: Color(0xFFE5E7EB),
      ),
    ),
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      color:
                          Color(0xFF6B7280),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF),
              ),
          ],
        ),
      ),
    ),
  );
}

}