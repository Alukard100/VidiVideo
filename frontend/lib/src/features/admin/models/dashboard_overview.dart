class DashboardOverview {
  const DashboardOverview({
    required this.activeAccounts,
    required this.totalVideos,
    required this.totalSubscriberVideos,
    required this.activeSubscribers,
    required this.totalTransactionValue,
    required this.totalRevenue,
    required this.totalTransactions,
    required this.totalReports,
    required this.pendingReports,
    required this.videoCompletionRate,
    required this.revenueTrend,
  });

  final int activeAccounts;
  final int totalVideos;
  final int totalSubscriberVideos;
  final int activeSubscribers;
  final double totalTransactionValue;
  final double totalRevenue;
  final int totalTransactions;
  final int totalReports;
  final int pendingReports;
  final double videoCompletionRate;
  final List<DashboardRevenuePoint> revenueTrend;

  factory DashboardOverview.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawTrend = json['revenueTrend'];

    return DashboardOverview(
      activeAccounts: _readInt(
        json['activeAccounts'],
      ),
      totalVideos: _readInt(
        json['totalVideos'],
      ),
      totalSubscriberVideos: _readInt(
        json['totalSubscriberVideos'],
      ),
      activeSubscribers: _readInt(
        json['activeSubscribers'],
      ),
      totalTransactionValue: _readDouble(
        json['totalTransactionValue'],
      ),
      totalRevenue: _readDouble(
        json['totalRevenue'],
      ),
      totalTransactions: _readInt(
        json['totalTransactions'],
      ),
      totalReports: _readInt(
        json['totalReports'],
      ),
      pendingReports: _readInt(
        json['pendingReports'],
      ),
      videoCompletionRate: _readDouble(
        json['videoCompletionRate'],
      ),
      revenueTrend: rawTrend is List
          ? rawTrend
              .whereType<Map<String, dynamic>>()
              .map(
                DashboardRevenuePoint.fromJson,
              )
              .toList()
          : const [],
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

class DashboardRevenuePoint {
  const DashboardRevenuePoint({
    required this.year,
    required this.month,
    required this.revenue,
  });

  final int year;
  final int month;
  final double revenue;

  factory DashboardRevenuePoint.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardRevenuePoint(
      year: DashboardOverview._readInt(
        json['year'],
      ),
      month: DashboardOverview._readInt(
        json['month'],
      ),
      revenue: DashboardOverview._readDouble(
        json['revenue'],
      ),
    );
  }
}