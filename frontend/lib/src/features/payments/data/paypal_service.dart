import '../../../core/network/api_client.dart';
import '../models/paypal_order.dart';

class PayPalPaymentService {
  PayPalPaymentService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<PayPalOrder> createOrder(
    String creatorId,
  ) async {
    final response =
        await _apiClient.postJson(
      '/api/PayPal/create-paypal-order',
      {
        'creatorId': creatorId,
      },
    );

    return PayPalOrder.fromJson(response);
  }

  Future<bool> captureOrder(
    String orderId,
  ) async {
    final response =
        await _apiClient.postJson(
      '/api/PayPal/capture',
      {
        'orderId': orderId,
      },
    );

    final value = response['value'];

    if (value is bool) {
      return value;
    }

    return value?.toString().toLowerCase()
        == 'true';
  }

  Future<String> createOnboarding() async {
    final response =
        await _apiClient.postJson(
      '/api/PayPal/onboarding',
      {},
    );

    final value =
        response['onboardingUrl'];

    if (value is! String ||
        value.isEmpty) {
      throw const ApiException(
        statusCode: 500,
        message:
            'Server did not return PayPal onboarding URL.',
      );
    }

    return value;
  }

  Future<bool> completeOnboarding() async {
    final response =
        await _apiClient.postJson(
      '/api/PayPal/onboarding/complete',
      {},
    );

    final value = response['value'];

    if (value is bool) {
      return value;
    }

    return value
            ?.toString()
            .toLowerCase() ==
        'true';
  }
}