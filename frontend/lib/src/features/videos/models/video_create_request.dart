import 'video_visibility.dart';

class VideoCreateRequest {
  const VideoCreateRequest({
    required this.categoryId,
    required this.caption,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.visibility,
    required this.isPublished,
  });

  final String categoryId;
  final String caption;
  final String videoUrl;
  final String thumbnailUrl;
  final VideoVisibility visibility;
  final bool isPublished;

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'caption': caption,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'visibility': visibility.value,
      'isPublished': isPublished,
    };
  }
}