import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import 'admin_navigation.dart';

class ContentReportsPage extends StatelessWidget {
  const ContentReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Content reports',
      navigationItems: adminNavigationItems(AppRoutes.adminReports),
      body: const EmptyState(
        title: 'Reported content',
        message: 'Add reported videos/comments review flow, resolution notes, and moderation actions here.',
      ),
    );
  }
}
