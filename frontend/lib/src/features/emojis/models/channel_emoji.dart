class ChannelEmoji {
  const ChannelEmoji({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.code,
    required this.imageUrl,
  });

  final String id;
  final String creatorId;
  final String creatorName;
  final String code;
  final String imageUrl;

  factory ChannelEmoji.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChannelEmoji(
      id: json['id']?.toString() ?? '',
      creatorId: json['creatorId']?.toString() ?? '',
      creatorName:
          json['creatorName']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }
}