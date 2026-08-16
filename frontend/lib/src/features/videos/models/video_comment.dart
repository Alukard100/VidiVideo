class VideoComment {
  const VideoComment({
    required this.id,
    required this.content,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final String content;
  final DateTime? createdAtUtc;
  final DateTime? updatedAtUtc;

  factory VideoComment.fromJson(Map<String, dynamic> json) {
    return VideoComment(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAtUtc: DateTime.tryParse(json['createdAtUtc']?.toString() ?? ''),
      updatedAtUtc: DateTime.tryParse(json['updatedAtUtc']?.toString() ?? ''),
    );
  }
}
