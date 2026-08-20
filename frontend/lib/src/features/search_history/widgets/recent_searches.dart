import 'package:flutter/material.dart';

import '../models/search_history_item.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({
    required this.items,
    required this.isLoading,
    required this.onPressed,
    required this.onDelete,
    required this.onClearAll,
    super.key,
  });

  final List<SearchHistoryItem> items;
  final bool isLoading;

  final ValueChanged<SearchHistoryItem>
      onPressed;

  final ValueChanged<SearchHistoryItem>
      onDelete;

  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        child: LinearProgressIndicator(),
      );
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        4,
        20,
        10,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent searches',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                child: const Text(
                  'Clear all',
                ),
              ),
            ],
          ),

          for (final item in items)
            InkWell(
              onTap: () => onPressed(item),
              borderRadius:
                  BorderRadius.circular(8),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      size: 19,
                      color:
                          Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.query,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color:
                              Color(0xFF374151),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      visualDensity:
                          VisualDensity.compact,
                      onPressed:
                          () => onDelete(item),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}