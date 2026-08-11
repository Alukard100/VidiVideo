import '../../features/categories/data/category_service.dart';
import '../../features/videos/data/video_service.dart';
import '../../features/auth/data/auth_service.dart';
import '../network/api_client.dart';
import '../storage/session_store.dart';

class AppServices {
  AppServices._();

  static final SessionStore sessionStore = SessionStore();

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
}