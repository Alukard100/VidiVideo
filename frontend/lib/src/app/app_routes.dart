class AppRoutes {
  const AppRoutes._();

  static const login = '/login';
  static const adminDashboard = '/admin';
  static const adminUsers = '/admin/users';
  static const adminReports = '/admin/reports';
  static const adminStaff = '/admin/staff';
  static const feed = '/feed';
  static const search = '/search';
  static const createVideo = '/create-video';
  static const following = '/following';
  static const profile = '/profile';
  static const userProfile = '/user-profile';
  static const videoViewer = '/video-viewer';
  static const subscriptions = '/subscriptions';
  static const mobileShell = '/mobile';
}

class VideoViewerRouteArguments {
  const VideoViewerRouteArguments({
    required this.videoId,
    this.showBackButton = true,
  });

  final String videoId;
  final bool showBackButton;
}
