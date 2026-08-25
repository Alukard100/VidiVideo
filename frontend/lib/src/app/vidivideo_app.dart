import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/admin/presentation/admin_dashboard_page.dart';
import '../features/admin/presentation/content_reports_page.dart';
import '../features/admin/presentation/refund_requests_page.dart';
import '../features/admin/presentation/staff_management_page.dart';
import '../features/admin/presentation/users_management_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/mobile/presentation/create/create_video_page.dart';
import '../features/mobile/presentation/feed_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/mobile/presentation/search_page.dart';
import '../features/mobile/presentation/subscriptions_page.dart';
import '../features/mobile/presentation/mobile_shell_page.dart';
import '../features/videos/presentation/video_viewer_page.dart';
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
        AppRoutes.register: (_) => const RegisterPage(),
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
        AppRoutes.mobileShell: (_) => const MobileShellPage(),
        AppRoutes.adminRefunds: (_) => const RefundRequestsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.userProfile) {
          final userId = settings.arguments?.toString();

          return MaterialPageRoute<void>(
            builder: (_) => ProfilePage(userId: userId),
          );
        }

        if (settings.name == AppRoutes.videoViewer) {
          final args = settings.arguments;

          if (args is VideoViewerRouteArguments) {
            return MaterialPageRoute<void>(
              builder: (_) => VideoViewerPage(
                videoId: args.videoId,
                showBackButton: args.showBackButton,
              ),
            );
          }

          final videoId = args?.toString() ?? '';

          return MaterialPageRoute<void>(
            builder: (_) => VideoViewerPage(videoId: videoId),
          );
        }

        return null;
      },
    );
  }
}
