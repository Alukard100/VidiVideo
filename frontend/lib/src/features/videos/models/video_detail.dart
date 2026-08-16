class VideoDetail {
  const VideoDetail({
    required this.id,
    required this.caption,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.creatorId,
    required this.creatorName,
    required this.categoryName,
    required this.isPublished,
    required this.visibility,
    required this.likeCount,
    required this.commentCount,
    required this.hashtags,
  });

  final String id;
  final String caption;
  final String videoUrl;
  final String thumbnailUrl;
  final String creatorId;
  final String creatorName;
  final String categoryName;
  final bool isPublished;
  final String visibility;
  final int likeCount;
  final int commentCount;
  final List<String> hashtags;

  factory VideoDetail.fromJson(Map<String, dynamic> json) {
    return VideoDetail(
      id: json['id']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      creatorId: json['creatorId']?.toString() ?? '',
      creatorName: json['creatorName']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      isPublished: json['isPublished'] == true,
      visibility: json['visibility']?.toString() ?? '',
      likeCount: _readInt(json['likeCount']),
      commentCount: _readInt(json['commentCount']),
      hashtags: _readStringList(json['hashtags']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _readStringList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value.map((item) => item.toString()).toList();
  }
}
