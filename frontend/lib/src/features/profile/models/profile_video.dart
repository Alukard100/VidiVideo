class ProfileVideo {
  const ProfileVideo({
    required this.id,
    required this.caption,
    required this.thumbnailUrl,
    required this.isLocked,
  });

  final String id;
  final String caption;
  final String thumbnailUrl;
  final bool isLocked;

  factory ProfileVideo.fromJson(Map<String, dynamic> json) {
    return ProfileVideo(
      id: json['id']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      isLocked: json['isLocked'] == true,
    );
  }
}
