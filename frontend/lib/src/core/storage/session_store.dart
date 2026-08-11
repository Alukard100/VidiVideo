class SessionStore {
  String? _accessToken;
  String? _role;

  String? get accessToken => _accessToken;
  String? get role => _role;

  bool get isAuthenticated {
    return _accessToken != null && _accessToken!.isNotEmpty;
  }

  void saveSession({
    required String accessToken,
    required String role,
  }) {
    _accessToken = accessToken;
    _role = role;
  }

  void clearSession() {
    _accessToken = null;
    _role = null;
  }
}
