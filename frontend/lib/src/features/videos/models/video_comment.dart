import '../../emojis/models/comment_emoji.dart';

class VideoComment {
  const VideoComment({
    required this.id,
    required this.content,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    required this.authorId,
    required this.authorDisplayName,
    required this.authorAvatarUrl,
    required this.emojis,
  });

  final String id;
  final String content;
  final DateTime? createdAtUtc;
  final DateTime? updatedAtUtc;
  final String authorId;
  final String authorDisplayName;
  final String? authorAvatarUrl;
  final List<CommentEmoji> emojis;

  factory VideoComment.fromJson(Map<String, dynamic> json) {
    return VideoComment(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAtUtc: DateTime.tryParse(json['createdAtUtc']?.toString() ?? ''),
      updatedAtUtc: DateTime.tryParse(json['updatedAtUtc']?.toString() ?? ''),
      authorId: json['authorId']?.toString() ?? '',
      authorDisplayName: json['authorDisplayName']?.toString() ?? '',
      authorAvatarUrl: json['authorAvatarUrl']?.toString(),
      emojis: (json['emojis'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map(CommentEmoji.fromJson)
          .toList() ??
        const [],
    );
  }
}
