import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_state.dart';

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscriptions')),
      body: const EmptyState(
        title: 'Creator subscriptions',
        message: 'Add PayPal-backed subscription checkout and subscription history here.',
      ),
    );
  }
}
