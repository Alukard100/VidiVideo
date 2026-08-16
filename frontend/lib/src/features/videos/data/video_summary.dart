class VideoSummary {
  const VideoSummary({
    required this.id,
    required this.caption,
    required this.creatorDisplayName,
    required this.thumbnailUrl,
    required this.visibility,
    required this.likeCount,
    required this.commentCount,
    required this.viewCount,
  });

  final String id;
  final String caption;
  final String creatorDisplayName;
  final String thumbnailUrl;
  final String visibility;
  final int likeCount;
  final int commentCount;
  final int viewCount;

  factory VideoSummary.fromJson(Map<String, dynamic> json) {
    return VideoSummary(
      id: json['id'] as String,
      caption: json['caption'] as String,
      creatorDisplayName: json['creatorDisplayName'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      visibility: json['visibility'] as String,
      likeCount: _readInt(json['likeCount']),
      commentCount: _readInt(json['commentCount']),
      viewCount: _readInt(json['viewCount']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
