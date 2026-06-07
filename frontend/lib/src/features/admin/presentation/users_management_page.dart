import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import 'admin_navigation.dart';

class UsersManagementPage extends StatelessWidget {
  const UsersManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Users',
      navigationItems: adminNavigationItems(AppRoutes.adminUsers),
      body: const EmptyState(
        title: 'User management',
        message: 'Add searchable user listing, status filters, suspend actions, and edit forms here.',
      ),
    );
  }
}
