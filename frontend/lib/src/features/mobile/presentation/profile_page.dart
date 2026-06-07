import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const EmptyState(
        title: 'User profile',
        message: 'Add profile editing, creator videos, premium videos, and account settings here.',
      ),
    );
  }
}
