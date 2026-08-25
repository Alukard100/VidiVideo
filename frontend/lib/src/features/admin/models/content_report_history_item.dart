class ContentReportHistoryItem {
  const ContentReportHistoryItem({
    required this.id,
    required this.reason,
    required this.status,
    required this.resolutionNote,
    required this.createdAtUtc,
    required this.reviewedAtUtc,
  });

  final String id;
  final String reason;
  final int status;
  final String? resolutionNote;
  final DateTime? createdAtUtc;
  final DateTime? reviewedAtUtc;

  factory ContentReportHistoryItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return ContentReportHistoryItem(
      id: json['id']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      status: int.tryParse(
            json['status']?.toString() ?? '',
          ) ??
          0,
      resolutionNote:
          json['resolutionNote']?.toString(),
      createdAtUtc: DateTime.tryParse(
        json['createdAtUtc']?.toString() ?? '',
      ),
      reviewedAtUtc: DateTime.tryParse(
        json['reviewedAtUtc']?.toString() ?? '',
      ),
    );
  }
}