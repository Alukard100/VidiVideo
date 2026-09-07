class CommentEmoji {
  const CommentEmoji({
    required this.code,
    required this.imageUrl,
  });

  final String code;
  final String imageUrl;

  factory CommentEmoji.fromJson(
    Map<String, dynamic> json,
  ) {
    return CommentEmoji(
      code: json['code']?.toString() ?? '',
      imageUrl:
          json['imageUrl']?.toString() ?? '',
    );
  }
}