import 'profile_video.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.userName,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.countryId,
    required this.countryName,
    required this.followersCount,
    required this.followingCount,
    required this.isSubscribed,
    required this.publicVideos,
    required this.subscriberOnlyVideos,
    this.email,
    this.status,
  });

  final String id;
  final String userName;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final String? countryId;
  final String? countryName;
  final int followersCount;
  final int followingCount;
  final bool isSubscribed;
  final List<ProfileVideo> publicVideos;
  final List<ProfileVideo> subscriberOnlyVideos;
  final String? email;
  final String? status;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      bio: json['bio']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      countryId: json['countryId']?.toString(),
      countryName: json['countryName']?.toString(),
      followersCount: _readInt(json['followersCount']),
      followingCount: _readInt(json['followingCount']),
      isSubscribed: json['isSubscribed'] == true,
      publicVideos: _readVideos(json['publicVideos']),
      subscriberOnlyVideos: _readVideos(json['subscriberOnlyVideos']),
      email: json['email']?.toString(),
      status: json['status']?.toString(),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<ProfileVideo> _readVideos(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map<String, dynamic>>()
        .map(ProfileVideo.fromJson)
        .toList();
  }
}
