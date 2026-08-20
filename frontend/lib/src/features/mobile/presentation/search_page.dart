import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../categories/models/category.dart';
import '../../search_history/models/search_history_item.dart';
import '../../search_history/widgets/recent_searches.dart';
import '../../videos/data/video_summary.dart';
import '../../videos/widgets/search_video_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _videoService = AppServices.videoService;
  final _searchHistoryService = AppServices.searchHistoryService;

  List<Category> _categories = [];
  List<VideoSummary> _videos = [];
  List<String> _parsedHashtags = [];
  List<SearchHistoryItem> _recentSearches =[];
  String? _selectedCategoryId;
  Timer? _debounce;
  bool _isLoading = true;
  String? _error;
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadSearchHistory();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final categories = await AppServices.categoryService.getAll();
      final videos = await _videoService.searchVideos(
        search: null,
        categoryId: null,
        hashtags: const [],
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
        _videos = videos;
        _isLoading = false;
      });
    } on ApiException catch (exception) {
      _setError('Search failed (${exception.statusCode}): ${exception.message}');
    } catch (exception) {
      _setError('Search failed: $exception');
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _performSearch);
  }

  Future<void> _performSearch({bool recordHistory = true}) async {
    final rawQuery = _searchController.text.trim();
    final hashtags = _extractHashtags(rawQuery);
    final searchText = _stripHashtags(rawQuery);

    setState(() {
      _isLoading = true;
      _error = null;
      _parsedHashtags = hashtags;
    });

    try {
      if (recordHistory && rawQuery.isNotEmpty) {
        unawaited(_recordSearch(rawQuery));
      }

      final videos = await _videoService.searchVideos(
        search: searchText.isEmpty ? null : searchText,
        categoryId: _selectedCategoryId,
        hashtags: hashtags,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } on ApiException catch (exception) {
      _setError('Search failed (${exception.statusCode}): ${exception.message}');
    } catch (exception) {
      _setError('Search failed: $exception');
    }
  }

  Future<void> _recordSearch(String query) async {
    if (!_hasSession()) {
      return;
    }

    try {
      await _searchHistoryService.create(query);

      await _loadSearchHistory();
    } catch (_) {
    }
  }

  Future<void> _clearSearchHistory() async {
    try {
      await _searchHistoryService.clear();

      if (!mounted) {
        return;
      }

      setState(() {
        _recentSearches = [];
      });

      _showMessage(
        'Search history cleared.',
      );
    } on ApiException catch (exception) {
      _showMessage(
        'Could not clear search history '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (exception) {
      _showMessage(
        'Could not clear search history: $exception',
      );
    }
  }

  Future<void> _loadSearchHistory() async {
    if (!_hasSession()) {
      return;
    }

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final history =
          await _searchHistoryService.getHistory(
        page: 1,
        pageSize: 5,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _recentSearches = history;
        _isLoadingHistory = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  bool _hasSession() {
    final token =
        AppServices.sessionStore.accessToken;

    return token != null && token.isNotEmpty;
  }

  Future<void> _deleteRecentSearch(
  SearchHistoryItem item,
  ) async {
    try {
      await _searchHistoryService.delete(
        item.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _recentSearches.removeWhere(
          (entry) => entry.id == item.id,
        );
      });
    } on ApiException catch (exception) {
      _showMessage(
        'Could not delete search '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }



  void _setError(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      _error = message;
      _isLoading = false;
    });
  }

  void _selectCategory(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _performSearch(recordHistory: false);
  }

  void _useRecentSearch(
    SearchHistoryItem item,
  ) {
    _debounce?.cancel();

    _searchController.text = item.query;

    _searchController.selection =
        TextSelection.collapsed(
      offset: item.query.length,
    );

    _performSearch(
      recordHistory: false,
    );
  }

  void _openVideo(VideoSummary video) {
    AppServices.mobileNavigation.openVideoFeed(
      videoIds: _videos.map((item) => item.id).toList(),
      initialVideoId: video.id,
    );
  }

  List<String> _extractHashtags(String value) {
    final matches = RegExp(r'(?:^|\s)#([A-Za-z0-9_]+)').allMatches(value);

    return matches
        .map((match) => match.group(1)!.toLowerCase())
        .toSet()
        .toList();
  }

  String _stripHashtags(String value) {
    return value.replaceAll(RegExp(r'(?:^|\s)#[A-Za-z0-9_]+'), ' ').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _performSearch(),
                decoration: InputDecoration(
                  hintText: 'Search videos, creators, hashtags...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF1F2F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _performSearch(recordHistory: false);
                          },
                          icon: const Icon(Icons.close, size: 18),
                        ),
                ),
              ),
            ),
            if (_searchController.text
              .trim()
              .isEmpty)
            RecentSearches(
              items: _recentSearches,
              isLoading: _isLoadingHistory,
              onPressed: _useRecentSearch,
              onDelete: _deleteRecentSearch,
              onClearAll: _clearSearchHistory,
            ),
            _CategoryFilters(
              categories: _categories,
              selectedCategoryId: _selectedCategoryId,
              onSelected: _selectCategory,
            ),
            if (_parsedHashtags.isNotEmpty)
              _ParsedHashtagRow(hashtags: _parsedHashtags),
            Expanded(
              child: _SearchBody(
                isLoading: _isLoading,
                error: _error,
                videos: _videos,
                onRetry: () => _performSearch(recordHistory: false),
                onVideoPressed: _openVideo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChipButton(
            label: 'All',
            selected: selectedCategoryId == null,
            onPressed: () => onSelected(null),
          ),
          for (final category in categories) ...[
            const SizedBox(width: 8),
            _FilterChipButton(
              label: category.name,
              selected: selectedCategoryId == category.id,
              onPressed: () => onSelected(category.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onPressed(),
      selectedColor: const Color(0xFF020011),
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF374151),
        fontSize: 12,
      ),
      showCheckmark: false,
      side: const BorderSide(color: Color(0xFFE5E7EB)),
      backgroundColor: Colors.white,
    );
  }
}

class _ParsedHashtagRow extends StatelessWidget {
  const _ParsedHashtagRow({required this.hashtags});

  final List<String> hashtags;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final hashtag in hashtags)
            Chip(
              label: Text('#$hashtag'),
              visualDensity: VisualDensity.compact,
              backgroundColor: const Color(0xFFF1F2F5),
              side: BorderSide.none,
            ),
        ],
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody({
    required this.isLoading,
    required this.error,
    required this.videos,
    required this.onRetry,
    required this.onVideoPressed,
  });

  final bool isLoading;
  final String? error;
  final List<VideoSummary> videos;
  final VoidCallback onRetry;
  final ValueChanged<VideoSummary> onVideoPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFF6B7280), size: 40),
              const SizedBox(height: 12),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF374151)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (videos.isEmpty) {
      return const Center(
        child: Text(
          'No videos found.',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 92),
      itemCount: videos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: .58,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        final video = videos[index];

        return SearchVideoTile(
          video: video,
          onTap: () => onVideoPressed(video),
        );
      },
    );
  }
}
