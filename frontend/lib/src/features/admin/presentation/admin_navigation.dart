import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../shared/widgets/responsive_scaffold.dart';

List<NavigationItem> adminNavigationItems(String selectedRoute) {
  return [
    NavigationItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      route: AppRoutes.adminDashboard,
      selected: selectedRoute == AppRoutes.adminDashboard,
    ),
    NavigationItem(
      label: 'Users',
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
    NavigationItem(
      label: 'Staff',
      icon: Icons.admin_panel_settings_outlined,
      route: AppRoutes.adminStaff,
      selected: selectedRoute == AppRoutes.adminStaff,
    ),
  ];
}
