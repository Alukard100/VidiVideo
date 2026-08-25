class ContentReportStats {
  const ContentReportStats({
    required this.pending,
    required this.resolved,
    required this.rejected,
  });

  final int pending;
  final int resolved;
  final int rejected;

  factory ContentReportStats.fromJson(
    Map<String, dynamic> json,
  ) {
    return ContentReportStats(
      pending: _readInt(json['pending']),
      resolved: _readInt(json['resolved']),
      rejected: _readInt(json['rejected']),
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