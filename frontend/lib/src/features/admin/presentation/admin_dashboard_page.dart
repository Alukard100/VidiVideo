import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import '../models/dashboard_overview.dart';
import 'admin_navigation.dart';
import 'widgets/admin_profile_menu.dart';

enum _ReportPeriod {
  allTime,
  thisMonth,
  last30Days,
  thisYear,
}

extension on _ReportPeriod {
  String get label {
    switch (this) {
      case _ReportPeriod.allTime:
        return 'All Time';

      case _ReportPeriod.thisMonth:
        return 'This Month';

      case _ReportPeriod.last30Days:
        return 'Last 30 Days';

      case _ReportPeriod.thisYear:
        return 'This Year';
    }
  }

  DateTime? get from {
    final now = DateTime.now().toUtc();

    switch (this) {
      case _ReportPeriod.allTime:
        return null;

      case _ReportPeriod.thisMonth:
        return DateTime.utc(
          now.year,
          now.month,
          1,
        );

      case _ReportPeriod.last30Days:
        return now.subtract(
          const Duration(days: 30),
        );

      case _ReportPeriod.thisYear:
        return DateTime.utc(
          now.year,
          1,
          1,
        );
    }
  }
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({
    super.key,
  });

  @override
  State<AdminDashboardPage> createState() =>
      _AdminDashboardPageState();
}

class _AdminDashboardPageState
    extends State<AdminDashboardPage> {
  late Future<DashboardOverview> _overviewFuture;

  _ReportPeriod _reportPeriod =
      _ReportPeriod.thisMonth;

  bool _isGeneratingRevenue = false;
  bool _isGeneratingVideos = false;

  @override
  void initState() {
    super.initState();

    _overviewFuture =
        AppServices.adminDashboardService
            .getOverview();
  }

  void _refresh() {
    setState(() {
      _overviewFuture =
          AppServices.adminDashboardService
              .getOverview();
    });
  }

  Future<void> _downloadRevenueReport() async {
    setState(() {
      _isGeneratingRevenue = true;
    });

    try {
      final bytes =
          await AppServices.adminDashboardService
              .getRevenueReport(
        from: _reportPeriod.from,
      );

      final file =
          await AppServices.adminDashboardService
              .saveReport(
        bytes: bytes,
        fileName:
            'revenue-report-${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (!mounted) return;

      _showMessage(
        'Revenue report saved to ${file.path}',
      );
    } on ApiException catch (exception) {
      _showMessage(
        'Unable to generate report '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (exception) {
      _showMessage(
        'Unable to generate revenue report.',
      );

      debugPrint(
        'REVENUE REPORT ERROR: $exception',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingRevenue = false;
        });
      }
    }
  }

  Future<void> _downloadVideoReport() async {
    setState(() {
      _isGeneratingVideos = true;
    });

    try {
      final bytes =
          await AppServices.adminDashboardService
              .getVideoAnalyticsReport(
        from: _reportPeriod.from,
      );

      final file =
          await AppServices.adminDashboardService
              .saveReport(
        bytes: bytes,
        fileName:
            'video-analytics-${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (!mounted) return;

      _showMessage(
        'Video analytics report saved to ${file.path}',
      );
    } on ApiException catch (exception) {
      _showMessage(
        'Unable to generate report '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (exception) {
      _showMessage(
        'Unable to generate video analytics report.',
      );

      debugPrint(
        'VIDEO REPORT ERROR: $exception',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingVideos = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

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
    return ResponsiveScaffold(
      title: 'Dashboard',
      navigationItems:
          adminNavigationItems(
        AppRoutes.adminDashboard,
      ),
      navigationFooter: const AdminProfileMenu(),

      body: Container(
        color: const Color(0xFFF8F9FB),
        child: FutureBuilder<DashboardOverview>(
          future: _overviewFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                snapshot.data == null) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError ||
                snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 42,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error
                              is ApiException
                          ? (snapshot.error
                                  as ApiException)
                              .message
                          : 'Unable to load dashboard.',
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      label:
                          const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final overview = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async {
                _refresh();
                await _overviewFuture;
              },
              child: ListView(
                padding:
                    const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Dashboard Overview',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'System overview, moderation statistics and reporting.',
                    style: TextStyle(
                      color:
                          Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildMetrics(overview),

                  const SizedBox(height: 20),

                  LayoutBuilder(
                    builder:
                        (context, constraints) {
                      final wide =
                          constraints.maxWidth >=
                              900;

                      if (wide) {
                        return Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Expanded(
                              flex: 3,
                              child:
                                  _RevenueChartCard(
                                points: overview
                                    .revenueTrend,
                              ),
                            ),

                            const SizedBox(
                              width: 16,
                            ),

                            Expanded(
                              flex: 2,
                              child:
                                  _buildReportsPanel(),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _RevenueChartCard(
                            points: overview
                                .revenueTrend,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          _buildReportsPanel(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),      
    );
  }

  Widget _buildMetrics(
    DashboardOverview overview,
  ) {
    final cards = [
      _MetricCard(
        title: 'Active Accounts',
        value:
            _compactNumber(
          overview.activeAccounts,
        ),
        subtitle:
            'Accounts currently active',
        icon: Icons.people_outline,
      ),

      _MetricCard(
        title: 'Total Videos',
        value:
            _compactNumber(
          overview.totalVideos,
        ),
        subtitle:
            '${_compactNumber(overview.totalSubscriberVideos)} subscriber-only',
        icon:
            Icons.video_library_outlined,
      ),

      _MetricCard(
        title: 'Active Subscribers',
        value:
            _compactNumber(
          overview.activeSubscribers,
        ),
        subtitle:
            'Current paid subscriptions',
        icon:
            Icons.workspace_premium_outlined,
      ),

      _MetricCard(
        title: 'Total Revenue',
        value:
            '\$${overview.totalRevenue.toStringAsFixed(2)}',
        subtitle:
            '${_compactNumber(overview.totalTransactions)} successful transactions',
        icon:
            Icons.attach_money_rounded,
      ),

      _MetricCard(
        title: 'Reported Content',
        value:
            _compactNumber(
          overview.totalReports,
        ),
        subtitle:
            '${_compactNumber(overview.pendingReports)} pending review',
        icon:
            Icons.flag_outlined,
      ),

      _MetricCard(
        title: 'Average Completion',
        value:
            '${overview.videoCompletionRate.toStringAsFixed(1)}%',
        subtitle:
            'Average video completion rate',
        icon:
            Icons.analytics_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= 1000
                ? 3
                : constraints.maxWidth >= 650
                    ? 2
                    : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio:
              columns == 3 ? 2.4 : 3,
          children: cards,
        );
      },
    );
  }

  Widget _buildReportsPanel() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
        side: const BorderSide(
          color:
              Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Generate Reports',
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Export system analytics as PDF.',
              style: TextStyle(
                color:
                    Color(0xFF6B7280),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<
                _ReportPeriod>(
              initialValue:
                  _reportPeriod,
              decoration:
                  const InputDecoration(
                labelText:
                    'Report period',
              ),
              items: [
                for (final period
                    in _ReportPeriod.values)
                  DropdownMenuItem(
                    value: period,
                    child:
                        Text(period.label),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _reportPeriod = value;
                });
              },
            ),

            const SizedBox(height: 18),

            OutlinedButton.icon(
              onPressed:
                  _isGeneratingRevenue
                      ? null
                      : _downloadRevenueReport,
              icon: _isGeneratingRevenue
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons
                          .picture_as_pdf_outlined,
                    ),
              label: const Text(
                'Revenue Report',
              ),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed:
                  _isGeneratingVideos
                      ? null
                      : _downloadVideoReport,
              icon: _isGeneratingVideos
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons
                          .video_file_outlined,
                    ),
              label: const Text(
                'Video Analytics Report',
              ),
            ),
          ],
        ),
      ),
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

class _MetricCard
    extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
        side: const BorderSide(
          color:
              Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color:
                          Color(0xFF4B5563),
                    ),
                  ),
                ),
                Icon(
                  icon,
                  size: 18,
                  color:
                      const Color(
                    0xFF6B7280,
                  ),
                ),
              ],
            ),

            const Spacer(),

            Text(
              value,
              style: const TextStyle(
                fontSize: 25,
                fontWeight:
                    FontWeight.w700,
                color:
                    Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitle,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color:
                    Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueChartCard
    extends StatelessWidget {
  const _RevenueChartCard({
    required this.points,
  });

  final List<DashboardRevenuePoint> points;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
        side: const BorderSide(
          color:
              Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Revenue Trend',
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              'Completed payments over the last six months.',
              style: TextStyle(
                fontSize: 12,
                color:
                    Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 280,
              child: points.isEmpty
                  ? const Center(
                      child: Text(
                        'No revenue data available.',
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment:
                            BarChartAlignment
                                .spaceAround,
                        borderData:
                            FlBorderData(
                          show: false,
                        ),
                        gridData:
                            const FlGridData(
                          show: true,
                          drawVerticalLine:
                              false,
                        ),
                        barTouchData:
                            BarTouchData(
                          enabled: true,
                        ),
                        titlesData:
                            FlTitlesData(
                          topTitles:
                              const AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles:
                                  false,
                            ),
                          ),
                          rightTitles:
                              const AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles:
                                  false,
                            ),
                          ),
                          bottomTitles:
                              AxisTitles(
                            sideTitles:
                                SideTitles(
                              showTitles:
                                  true,
                              getTitlesWidget:
                                  (value,
                                      meta) {
                                final index =
                                    value.toInt();

                                if (index < 0 ||
                                    index >=
                                        points
                                            .length) {
                                  return const SizedBox
                                      .shrink();
                                }

                                return Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    top: 8,
                                  ),
                                  child: Text(
                                    _monthLabel(
                                      points[index]
                                          .month,
                                    ),
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          11,
                                      color:
                                          Color(
                                        0xFF6B7280,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (var index = 0;
                              index <
                                  points.length;
                              index++)
                            BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY:
                                      points[index]
                                          .revenue,
                                  width: 26,
                                  borderRadius:
                                      const BorderRadius
                                          .vertical(
                                    top:
                                        Radius.circular(
                                      4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }
}