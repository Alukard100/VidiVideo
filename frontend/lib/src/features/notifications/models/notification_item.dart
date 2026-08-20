class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAtUtc,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime? createdAtUtc;

  factory NotificationItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isRead: json['isRead'] == true,
      createdAtUtc: DateTime.tryParse(
        json['createdAtUtc']?.toString() ?? '',
      ),
    );
  }
}