class VideoDetail {
  const VideoDetail({
    required this.id,
    required this.caption,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.creatorId,
    required this.creatorName,
    required this.creatorAvatarUrl,
    required this.categoryName,
    required this.isPublished,
    required this.visibility,
    required this.likeCount,
    required this.commentCount,
    required this.viewCount,
    required this.isLocked,
    required this.hashtags,
    this.recommendationReason,
    this.recommendationScore,
  });

  final String id;
  final String caption;
  final String videoUrl;
  final String thumbnailUrl;
  final String creatorId;
  final String creatorName;
  final String? creatorAvatarUrl;
  final String categoryName;
  final bool isPublished;
  final String visibility;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final bool isLocked;
  final List<String> hashtags;
  final String? recommendationReason;
  final double? recommendationScore;

  factory VideoDetail.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final videoUrl = json['videoUrl']?.toString();

    return VideoDetail(
      id: id,
      caption: json['caption']?.toString() ?? '',
      videoUrl: _playbackUrlFor(id, videoUrl),
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      creatorId: json['creatorId']?.toString() ?? '',
      creatorName: json['creatorName']?.toString() ??
          json['creatorDisplayName']?.toString() ??
          '',
      creatorAvatarUrl: json['creatorAvatarUrl']?.toString(),
      categoryName: json['categoryName']?.toString() ?? '',
      isPublished: json['isPublished'] == true,
      visibility: json['visibility']?.toString() ?? '',
      likeCount: _readInt(json['likeCount']),
      commentCount: _readInt(json['commentCount']),
      viewCount: _readInt(json['viewCount']),
      isLocked: json['isLocked'] == true,
      hashtags: _readStringList(json['hashtags']),
      recommendationReason: json['recommendationReason']?.toString(),
      recommendationScore: _readDouble(json['recommendationScore']),
    );
  }

  static String _streamUrlFor(String id) {
    return id.isEmpty ? '' : '/api/Video/$id/stream';
  }

  static String _playbackUrlFor(String id, String? value) {
    final url = value?.trim() ?? '';

    if (url.contains('/stream')) {
      return url;
    }

    return _streamUrlFor(id);
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double? _readDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static List<String> _readStringList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value.map((item) => item.toString()).toList();
  }
}
