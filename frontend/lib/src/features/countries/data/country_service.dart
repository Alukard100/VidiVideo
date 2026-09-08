import '../../../core/network/api_client.dart';
import '../../../shared/models/paged_result.dart';
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

  Future<PagedResult<Country>> getPage({
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response =
        await _apiClient.getJson(
      '/api/Country/getall',
      queryParameters: {
        'Page': page,
        'PageSize': pageSize,
        if (search != null &&
            search.trim().isNotEmpty)
          'Search': search.trim(),
      },
    );

    if (response
        is! Map<String, dynamic>) {
      throw const ApiException(
        statusCode: 500,
        message:
            'Unexpected countries response.',
      );
    }

    return PagedResult<Country>.fromJson(
      response,
      Country.fromJson,
    );
  }

  Future<void> create({
    required String name,
    required String code,
  }) async {
    await _apiClient.postJson(
      '/api/Country/create',
      {
        'name': name,
        'code': code,
      },
    );
  }

  Future<void> update({
    required String id,
    required String name,
    required String code,
  }) async {
    await _apiClient.patchJson(
      '/api/Country/update',
      {
        'id': id,
        'name': name,
        'code': code,
      },
    );
  }

  Future<void> delete(
    String id,
  ) async {
    await _apiClient.deleteJson(
      '/api/Country/$id',
      const {},
    );
  }
}
