import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_state.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search videos, hashtags, or creators',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: EmptyState(
              title: 'Search results',
              message: 'Connect this screen to video and creator search endpoints.',
            ),
          ),
        ],
      ),
    );
  }
}
