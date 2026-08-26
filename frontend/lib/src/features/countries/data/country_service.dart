import '../../../core/network/api_client.dart';
import '../models/country.dart';

class CountryService {
  // ignore: prefer_initializing_formals
  CountryService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Country>> getAll() async {
    final response = await _apiClient.getJson(
      '/api/Country/getall',
      queryParameters: {
        'Page': '1',
        'PageSize': '30',
      },
    );

    final items = response['items'];

    if (items is! List) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected countries response.',
      );
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(Country.fromJson)
        .toList();
  }
}
