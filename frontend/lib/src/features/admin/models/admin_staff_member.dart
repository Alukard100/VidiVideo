class AdminStaffMember {
  const AdminStaffMember({
    required this.id,
    required this.userName,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.role,
    required this.createdAtUtc,
  });

  final String id;
  final String userName;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final DateTime? createdAtUtc;

  factory AdminStaffMember.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminStaffMember(
      id: json['id']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      role: json['role']?.toString() ?? '',
      createdAtUtc: DateTime.tryParse(
        json['createdAtUtc']?.toString() ?? '',
      ),
    );
  }
}