import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import 'admin_navigation.dart';

class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Staff',
      navigationItems: adminNavigationItems(AppRoutes.adminStaff),
      body: const EmptyState(
        title: 'Staff management',
        message: 'Add staff roles, permissions, and staff account CRUD here.',
      ),
    );
  }
}
