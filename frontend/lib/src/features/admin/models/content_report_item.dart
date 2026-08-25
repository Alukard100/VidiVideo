class ContentReportItem {
  const ContentReportItem({
    required this.reportId,
    required this.reporterId,
    required this.reporterName,
    required this.reason,
    required this.status,
    required this.createdAtUtc,
  });

  final String reportId;
  final String reporterId;
  final String reporterName;
  final String reason;
  final int status;
  final DateTime? createdAtUtc;

  factory ContentReportItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ContentReportItem(
      reportId:
          json['reportId']?.toString() ?? '',
      reporterId:
          json['reporterId']?.toString() ?? '',
      reporterName:
          json['reporterName']?.toString() ?? '',
      reason:
          json['reason']?.toString() ?? '',
      status: _readInt(json['status']),
      createdAtUtc: DateTime.tryParse(
        json['createdAtUtc']?.toString() ?? '',
      ),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}