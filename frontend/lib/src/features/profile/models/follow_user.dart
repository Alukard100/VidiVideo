class FollowUser {
  const FollowUser({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.isFollowing,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isFollowing;

  factory FollowUser.fromJson(Map<String, dynamic> json) {
    return FollowUser(
      id: json['id']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      isFollowing: json['isFollowing'] == true,
    );
  }
}
