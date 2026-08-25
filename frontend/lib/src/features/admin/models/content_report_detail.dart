import 'content_report_item.dart';

class ContentReportDetail {
  const ContentReportDetail({
    required this.contentId,
    required this.contentType,
    required this.creatorId,
    required this.creatorName,
    required this.contentPreview,
    required this.videoStreamUrl,
    required this.isDeleted,
    required this.reports,
  });

  final String contentId;
  final String contentType;
  final String creatorId;
  final String creatorName;
  final String contentPreview;
  final String? videoStreamUrl;
  final bool isDeleted;
  final List<ContentReportItem> reports;

  factory ContentReportDetail.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawReports = json['reports'];

    return ContentReportDetail(
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
      videoStreamUrl:
          json['videoStreamUrl']?.toString(),
      isDeleted: json['isDeleted'] == true,
      reports: rawReports is List
          ? rawReports
              .whereType<Map<String, dynamic>>()
              .map(ContentReportItem.fromJson)
              .toList()
          : const [],
    );
  }
}