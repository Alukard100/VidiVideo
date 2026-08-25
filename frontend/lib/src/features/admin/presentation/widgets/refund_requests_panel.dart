import 'package:flutter/material.dart';

import '../../../../core/dependency/app_services.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/paged_result.dart';
import '../../../refunds/models/refund_request.dart';

class RefundRequestsPanel extends StatefulWidget {
  const RefundRequestsPanel({
    super.key,
  });

  @override
  State<RefundRequestsPanel> createState() =>
      _RefundRequestsPanelState();
}

class _RefundRequestsPanelState
    extends State<RefundRequestsPanel> {
  int _page = 1;
  static const int _pageSize = 10;

  int? _status = 1;

  late Future<PagedResult<RefundRequestItem>>
      _requestsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _requestsFuture =
        AppServices.refundService
            .getRefundRequests(
      status: _status,
      page: _page,
      pageSize: _pageSize,
    );
  }

  void _refresh() {
    setState(() {
      _load();
    });
  }

  Future<void> _approve(
    RefundRequestItem request,
  ) async {
    final confirmed = await _confirm(
      title: 'Approve refund?',
      message:
          'Refund ${request.amount.toStringAsFixed(2)} '
          '${request.currency} to '
          '${request.subscriberName}?',
      confirmLabel: 'Approve',
    );

    if (!mounted || confirmed != true) {
      return;
    }

    try {
      await AppServices.refundService.approve(
        refundRequestId: request.id,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Refund approved.',
      );

      _refresh();
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Refund failed '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Refund could not be completed.',
      );
    }
  }

  Future<void> _reject(
    RefundRequestItem request,
  ) async {
    final confirmed = await _confirm(
      title: 'Reject refund request?',
      message:
          'Reject refund request from '
          '${request.subscriberName}?',
      confirmLabel: 'Reject',
    );

    if (!mounted || confirmed != true) {
      return;
    }

    try {
      await AppServices.refundService.reject(
        refundRequestId: request.id,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Refund request rejected.',
      );

      _refresh();
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Reject failed '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Refund request could not be rejected.',
      );
    }
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Refund Requests',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Review subscription refund requests.',
                        style: TextStyle(
                          color:
                              Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: 170,
                  child:
                      DropdownButtonFormField<int?>(
                    initialValue: _status,
                    decoration:
                        const InputDecoration(
                      labelText: 'Status',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text('All'),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('Approved'),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('Rejected'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _status = value;
                        _page = 1;
                        _load();
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            FutureBuilder<
                PagedResult<RefundRequestItem>>(
              future: _requestsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                        ConnectionState.waiting &&
                    snapshot.data == null) {
                  return const SizedBox(
                    height: 180,
                    child: Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  final error = snapshot.error;

                  return Padding(
                    padding:
                        const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          error is ApiException
                              ? error.message
                              : 'Unable to load refund requests.',
                        ),
                        const SizedBox(height: 10),
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

                final result =
                    snapshot.data;

                if (result == null ||
                    result.items.isEmpty) {
                  return const Padding(
                    padding:
                        EdgeInsets.symmetric(
                      vertical: 34,
                    ),
                    child: Center(
                      child: Text(
                        'No refund requests.',
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(
                            label:
                                Text('Subscriber'),
                          ),
                          DataColumn(
                            label:
                                Text('Creator'),
                          ),
                          DataColumn(
                            label:
                                Text('Amount'),
                          ),
                          DataColumn(
                            label:
                                Text('Requested'),
                          ),
                          DataColumn(
                            label:
                                Text('Status'),
                          ),
                          DataColumn(
                            label:
                                Text('Actions'),
                          ),
                        ],
                        rows: [
                          for (final request
                              in result.items)
                            DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    request
                                        .subscriberName,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    request
                                        .creatorName,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${request.amount.toStringAsFixed(2)} '
                                    '${request.currency}',
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _formatDate(
                                      request
                                          .requestedAtUtc,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  _StatusChip(
                                    request:
                                        request,
                                  ),
                                ),
                                DataCell(
                                  request.isPending
                                      ? Row(
                                          mainAxisSize:
                                              MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              tooltip:
                                                  'Approve',
                                              onPressed:
                                                  () => _approve(
                                                request,
                                              ),
                                              icon:
                                                  const Icon(
                                                Icons
                                                    .check_circle_outline,
                                              ),
                                            ),
                                            IconButton(
                                              tooltip:
                                                  'Reject',
                                              onPressed:
                                                  () => _reject(
                                                request,
                                              ),
                                              icon:
                                                  const Icon(
                                                Icons
                                                    .cancel_outlined,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const Text(
                                          'Reviewed',
                                        ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        Text(
                          'Page ${result.page}',
                          style: const TextStyle(
                            color:
                                Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: result.page > 1
                              ? () {
                                  setState(() {
                                    _page--;
                                    _load();
                                  });
                                }
                              : null,
                          icon: const Icon(
                            Icons.chevron_left,
                          ),
                        ),
                        IconButton(
                          onPressed:
                              result.page *
                                          result.pageSize <
                                      result.totalCount
                                  ? () {
                                      setState(() {
                                        _page++;
                                        _load();
                                      });
                                    }
                                  : null,
                          icon: const Icon(
                            Icons.chevron_right,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return '-';
    }

    final local = value.toLocal();

    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.'
        '${local.year}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.request,
  });

  final RefundRequestItem request;

  @override
  Widget build(BuildContext context) {
    late final Color background;
    late final Color foreground;

    if (request.isApproved) {
      background =
          const Color(0xFFDCFCE7);
      foreground =
          const Color(0xFF166534);
    } else if (request.isRejected) {
      background =
          const Color(0xFFFEE2E2);
      foreground =
          const Color(0xFF991B1B);
    } else {
      background =
          const Color(0xFFFEF3C7);
      foreground =
          const Color(0xFF92400E);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(999),
      ),
      child: Text(
        request.statusLabel,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }
}