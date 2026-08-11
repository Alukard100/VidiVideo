import 'package:vidivideo_app/src/core/network/api_client.dart';
import 'package:vidivideo_app/src/features/auth/models/login_request.dart';
import 'package:vidivideo_app/src/features/auth/models/login_response.dart';

class AuthService {

  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<LoginResponse> login(
      String username,
      String password,
  ) async {
    final request = LoginRequest(
      userName: username,
      password: password,
    );

    final response = await _apiClient.postJson('/api/auth/login', request.toJson());

    return LoginResponse.fromJson(response);
  }

}