class AdminUserSummary {
  const AdminUserSummary({
    required this.id,
    required this.userName,
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    required this.createdAtUtc,
    required this.videoCount,
    required this.followersCount,
    required this.status,
  });

  final String id;
  final String userName;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final DateTime? createdAtUtc;
  final int videoCount;
  final int followersCount;
  final String status;

  factory AdminUserSummary.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminUserSummary(
      id: json['id']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      displayName:
          json['displayName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      createdAtUtc: DateTime.tryParse(
        json['createdAtUtc']?.toString() ?? '',
      ),
      videoCount: _readInt(json['videoCount']),
      followersCount:
          _readInt(json['followersCount']),
      status: json['status']?.toString() ?? '',
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}