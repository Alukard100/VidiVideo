import '../../../core/network/api_client.dart';
import '../../../shared/models/paged_result.dart';
import '../models/category.dart';

class CategoryService {
  // ignore: prefer_initializing_formals
  CategoryService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Category>> getAll() async {
    const pageSize = 100;
    final categories = <Category>[];
    var page = 1;

    while (true) {
      final result = await getPage(
        page: page,
        pageSize: pageSize,
      );

      categories.addAll(result.items);

      if (categories.length >= result.totalCount || result.items.isEmpty) {
        return categories;
      }

      page++;
    }
  }

  Future<PagedResult<Category>> getPage({
    String? search,
    int page = 1,
    int pageSize = 10,
  }) async {
    final response =
        await _apiClient.getJson(
      '/api/Category/getall',
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
            'Unexpected categories response.',
      );
    }

    return PagedResult<Category>.fromJson(
      response,
      Category.fromJson,
    );
  }

  Future<void> create({
    required String name,
  }) async {
    await _apiClient.postJson(
      '/api/Category/create',
      {
        'categoryName': name,
      },
    );
  }

  Future<void> update({
    required String id,
    required String name,
  }) async {
    await _apiClient.patchJson(
      '/api/Category/update',
      {
        'id': id,
        'name': name,
      },
    );
  }

  Future<void> delete(
    String id,
  ) async {
    await _apiClient.deleteJson(
      '/api/Category/$id',
      const {},
    );
  }
}
