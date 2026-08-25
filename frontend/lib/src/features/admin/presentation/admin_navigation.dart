import 'package:flutter/material.dart';
import 'package:vidivideo_app/src/core/dependency/app_services.dart';

import '../../../app/app_routes.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

List<NavigationItem> adminNavigationItems(String selectedRoute) {

  final role = AppServices.sessionStore.role?.toLowerCase();

  final canManageStaff = role == 'admin' || role == 'super admin';

  return [
    NavigationItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      route: AppRoutes.adminDashboard,
      selected: selectedRoute == AppRoutes.adminDashboard,
    ),
    NavigationItem(
      label: 'User Management',
      icon: Icons.people_alt_outlined,
      route: AppRoutes.adminUsers,
      selected: selectedRoute == AppRoutes.adminUsers,
    ),
    NavigationItem(
      label: 'Reports',
      icon: Icons.flag_outlined,
      route: AppRoutes.adminReports,
      selected: selectedRoute == AppRoutes.adminReports,
    ),
    if (canManageStaff)
      NavigationItem(
        label: 'Refund Requests',
        icon: Icons.currency_exchange_outlined,
        route: AppRoutes.adminRefunds,
        selected:
            selectedRoute == AppRoutes.adminRefunds,
      ),
    if (canManageStaff)
      NavigationItem(
        label: 'Staff Management',
        icon: Icons.admin_panel_settings_outlined,
        route: AppRoutes.adminStaff,
        selected: selectedRoute == AppRoutes.adminStaff,
      ),
  ];
}
