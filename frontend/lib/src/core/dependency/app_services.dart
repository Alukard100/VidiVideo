import '../../features/categories/data/category_service.dart';
import '../../features/countries/data/country_service.dart';
import '../../features/mobile/navigation/mobile_navigation_controller.dart';
import '../../features/profile/data/profile_service.dart';
import '../../features/videos/data/video_service.dart';
import '../../features/auth/data/auth_service.dart';
import '../network/api_client.dart';
import '../storage/session_store.dart';
import '../utils/profile_refresh_notifier.dart';

class AppServices {
  AppServices._();

  static final MobileNavigationController mobileNavigation =
      MobileNavigationController();

  static final SessionStore sessionStore = SessionStore();

  static final profileRefreshNotifier = ProfileRefreshNotifier();

  static final ApiClient apiClient = ApiClient(
    sessionStore: sessionStore,
  );

  static final AuthService authService = AuthService(
    apiClient: apiClient,
  );

  static final VideoService videoService = VideoService(
    apiClient: apiClient,
  );

  static final CategoryService categoryService = CategoryService(
    apiClient: apiClient,
  );

  static final CountryService countryService = CountryService(
    apiClient: apiClient,
  );

  static final ProfileService profileService = ProfileService(
    apiClient: apiClient,
  );
}
