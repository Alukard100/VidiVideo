class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rawItems = json['items'];

    final items = rawItems is List
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(fromJson)
            .toList()
        : <T>[];

    return PagedResult<T>(
      items: items,
      totalCount: _readInt(
        json['totalCount'] ?? json['total'],
      ),
      page: _readInt(json['page']),
      pageSize: _readInt(json['pageSize']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}