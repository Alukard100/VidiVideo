class PayPalOrder {
  const PayPalOrder({
    required this.orderId,
    required this.approvalUrl,
  });

  final String orderId;
  final String approvalUrl;

  factory PayPalOrder.fromJson(
    Map<String, dynamic> json,
  ) {
    return PayPalOrder(
      orderId:
          json['orderId']?.toString() ?? '',
      approvalUrl:
          json['approvalUrl']?.toString() ?? '',
    );
  }
}