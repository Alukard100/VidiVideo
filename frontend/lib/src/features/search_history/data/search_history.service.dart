import '../../../core/network/api_client.dart';
import '../models/search_history_item.dart';

class SearchHistoryService {
  SearchHistoryService({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<void> create(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      return;
    }

    await _apiClient.postJson(
      '/api/SearchHistory',
      {
        'query': trimmed,
      },
    );
  }

  Future<List<SearchHistoryItem>> getHistory({
    int page = 1,
    int pageSize = 5,
  }) async {
    final response = await _apiClient.getJson(
      '/api/SearchHistory/history',
      queryParameters: {
        'Page': page,
        'PageSize': pageSize,
      },
    );

    if (response is! Map<String, dynamic>) {
      return const [];
    }

    final items = response['items'];

    if (items is! List) {
      return const [];
    }

    return items
        .whereType<Map<String, dynamic>>()
        .map(SearchHistoryItem.fromJson)
        .where((item) => item.query.isNotEmpty)
        .toList();
  }

  Future<void> delete(String id) async {
    await _apiClient.deleteJson(
      '/api/SearchHistory/$id',
      {},
    );
  }

  Future<void> clear() async {
    await _apiClient.deleteJson(
      '/api/SearchHistory/clear',
      {},
    );
  }

  Future<void> recordSearch(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      return;
    }

    await _apiClient.postJson(
      '/api/SearchHistory',
      {
        'query': trimmed,
      },
    );
  }
}

