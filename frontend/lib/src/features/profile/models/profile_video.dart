class ProfileVideo {
  const ProfileVideo({
    required this.id,
    required this.caption,
    required this.thumbnailUrl,
    required this.visibility,
    required this.isPublished,
    required this.isLocked,
  });

  final String id;
  final String caption;
  final String thumbnailUrl;
  final String visibility;
  final bool isPublished;
  final bool isLocked;

  factory ProfileVideo.fromJson(Map<String, dynamic> json) {
    return ProfileVideo(
      id: json['id']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      visibility: json['visibility']?.toString() ?? '',
      isPublished: json['isPublished'] == true,
      isLocked: json['isLocked'] == true,
    );
  }
}
