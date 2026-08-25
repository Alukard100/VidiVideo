class RefundRequestItem {
  const RefundRequestItem({
    required this.id,
    required this.paymentId,
    required this.subscriberId,
    required this.subscriberName,
    required this.creatorId,
    required this.creatorName,
    required this.amount,
    required this.currency,
    required this.status,
    required this.requestedAtUtc,
    required this.updatedAtUtc,
    required this.reviewedById,
  });

  final String id;
  final String paymentId;

  final String subscriberId;
  final String subscriberName;

  final String creatorId;
  final String creatorName;

  final double amount;
  final String currency;

  final int status;

  final DateTime? requestedAtUtc;
  final DateTime? updatedAtUtc;

  final String? reviewedById;

  factory RefundRequestItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return RefundRequestItem(
      id: json['id']?.toString() ?? '',
      paymentId:
          json['paymentId']?.toString() ?? '',

      subscriberId:
          json['subscriberId']?.toString() ?? '',
      subscriberName:
          json['subscriberName']?.toString() ?? '',

      creatorId:
          json['creatorId']?.toString() ?? '',
      creatorName:
          json['creatorName']?.toString() ?? '',

      amount: _readDouble(json['amount']),
      currency:
          json['currency']?.toString() ?? 'USD',

      status: _readInt(json['status']),

      requestedAtUtc: DateTime.tryParse(
        json['requestedAtUtc']?.toString() ?? '',
      ),
      updatedAtUtc: DateTime.tryParse(
        json['updatedAtUtc']?.toString() ?? '',
      ),

      reviewedById:
          json['reviewedById']?.toString(),
    );
  }

  bool get isPending => status == 1;
  bool get isApproved => status == 2;
  bool get isRejected => status == 3;

  String get statusLabel {
    switch (status) {
      case 1:
        return 'Pending';
      case 2:
        return 'Approved';
      case 3:
        return 'Rejected';
      default:
        return 'Unknown';
    }
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

  static double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}