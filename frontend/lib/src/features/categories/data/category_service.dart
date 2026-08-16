import '../../../core/network/api_client.dart';
import '../models/category.dart';

class CategoryService {
  // ignore: prefer_initializing_formals
  CategoryService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<Category>> getAll() async {
    final response = await _apiClient.getJson('/api/Category/getall', );

    if (response is! List) {
      throw const ApiException(
        statusCode: 500,
        message: 'Unexpected categories response.',
      );
    }

    return response.map(
      (e) => Category.fromJson(
        e as Map<String, dynamic>
      ),
    ).toList();
    
  }
}
