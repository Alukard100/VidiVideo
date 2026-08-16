import '../../../core/network/api_client.dart';
import '../models/country.dart';

class CountryService {
  // ignore: prefer_initializing_formals
  CountryService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Country>> getAll() async {
    final response = await _apiClient.getJson('/api/Country/getall');

    if (response is! List) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected countries response.',
      );
    }

    return response
        .map((item) => Country.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
