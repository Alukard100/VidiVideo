class SearchHistoryItem {
  const SearchHistoryItem({
    required this.id,
    required this.query,
    required this.createdAtUtc,
  });

  final String id;
  final String query;
  final DateTime? createdAtUtc;

  factory SearchHistoryItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return SearchHistoryItem(
      id: json['id']?.toString() ?? '',
      query: json['query']?.toString() ??
          json['searchText']?.toString() ??
          '',
      createdAtUtc: DateTime.tryParse(
        json['createdAtUtc']?.toString() ?? '',
      ),
    );
  }
}