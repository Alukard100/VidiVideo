import 'video_visibility.dart';

class VideoCreateRequest {
  const VideoCreateRequest({
    required this.categoryId,
    required this.caption,
    required this.visibility,
    required this.isPublished,
    this.earlyAccessDays,
  });

  final String categoryId;
  final String caption;
  final VideoVisibility visibility;
  final bool isPublished;
  final int? earlyAccessDays;

  Map<String, String> toFormFields() {
    return {
      'CategoryId': categoryId,
      'Caption': caption,
      'Visibility': visibility.value.toString(),
      'IsPublished': isPublished.toString(),
      if (earlyAccessDays != null)
        'EarlyAccessDays': earlyAccessDays.toString(),
    };
  }
}