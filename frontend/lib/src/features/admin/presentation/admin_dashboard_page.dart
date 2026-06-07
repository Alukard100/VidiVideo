import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import 'admin_navigation.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Admin dashboard',
      navigationItems: adminNavigationItems(AppRoutes.adminDashboard),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          const _MetricsGrid(),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Moderation queue'),
                  SizedBox(height: 12),
                  _QueueRow(label: 'Reported videos', value: '0'),
                  _QueueRow(label: 'Reported comments', value: '0'),
                  _QueueRow(label: 'Suspended accounts', value: '0'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context) {
    final metrics = const [
      ('Active users', '0'),
      ('Published videos', '0'),
      ('Monthly subscriptions', '0'),
      ('Monthly revenue', '\$0'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 4 : 2;

        return GridView.count(
          crossAxisCount: columns,
          childAspectRatio: 1.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final metric in metrics)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(metric.$1),
                      const Spacer(),
                      Text(metric.$2, style: Theme.of(context).textTheme.headlineSmall),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(value),
    );
  }
}
