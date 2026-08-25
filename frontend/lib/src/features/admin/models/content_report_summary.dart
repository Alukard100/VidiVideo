class ContentReportSummary {
  const ContentReportSummary({
    required this.contentId,
    required this.contentType,
    required this.creatorId,
    required this.creatorName,
    required this.contentPreview,
    required this.reportCount,
    required this.status,
    required this.lastReportedAtUtc,
  });

  final String contentId;
  final String contentType;
  final String creatorId;
  final String creatorName;
  final String contentPreview;
  final int reportCount;
  final int status;
  final DateTime? lastReportedAtUtc;

  factory ContentReportSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return ContentReportSummary(
      contentId:
          json['contentId']?.toString() ?? '',
      contentType:
          json['contentType']?.toString() ?? '',
      creatorId:
          json['creatorId']?.toString() ?? '',
      creatorName:
          json['creatorName']?.toString() ?? '',
      contentPreview:
          json['contentPreview']?.toString() ?? '',
      reportCount:
          _readInt(json['reportCount']),
      status:
          _readInt(json['status']),
      lastReportedAtUtc: DateTime.tryParse(
        json['lastReportedAtUtc']
                ?.toString() ??
            '',
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