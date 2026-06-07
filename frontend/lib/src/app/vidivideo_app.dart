import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/admin/presentation/admin_dashboard_page.dart';
import '../features/admin/presentation/content_reports_page.dart';
import '../features/admin/presentation/staff_management_page.dart';
import '../features/admin/presentation/users_management_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/mobile/presentation/create_video_page.dart';
import '../features/mobile/presentation/feed_page.dart';
import '../features/mobile/presentation/profile_page.dart';
import '../features/mobile/presentation/search_page.dart';
import '../features/mobile/presentation/subscriptions_page.dart';
import 'app_routes.dart';

class VidiVideoApp extends StatelessWidget {
  const VidiVideoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VidiVideo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.adminDashboard: (_) => const AdminDashboardPage(),
        AppRoutes.adminUsers: (_) => const UsersManagementPage(),
        AppRoutes.adminReports: (_) => const ContentReportsPage(),
        AppRoutes.adminStaff: (_) => const StaffManagementPage(),
        AppRoutes.feed: (_) => const FeedPage(),
        AppRoutes.search: (_) => const SearchPage(),
        AppRoutes.createVideo: (_) => const CreateVideoPage(),
        AppRoutes.following: (_) => const FeedPage(feedMode: FeedMode.following),
        AppRoutes.profile: (_) => const ProfilePage(),
        AppRoutes.subscriptions: (_) => const SubscriptionsPage(),
      },
    );
  }
}
