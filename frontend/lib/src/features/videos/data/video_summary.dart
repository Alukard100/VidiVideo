class VideoSummary {
  const VideoSummary({
    required this.id,
    required this.caption,
    required this.creatorDisplayName,
    required this.thumbnailUrl,
    required this.visibility,
    required this.likeCount,
    required this.commentCount,
  });

  final String id;
  final String caption;
  final String creatorDisplayName;
  final String thumbnailUrl;
  final String visibility;
  final int likeCount;
  final int commentCount;

  factory VideoSummary.fromJson(Map<String, dynamic> json) {
    return VideoSummary(
      id: json['id'] as String,
      caption: json['caption'] as String,
      creatorDisplayName: json['creatorDisplayName'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      visibility: json['visibility'] as String,
      likeCount: json['likeCount'] as int,
      commentCount: json['commentCount'] as int,
    );
  }
}
