class SessionStore {
  String? _accessToken;
  String? _role;
  int _revision = 0;

  String? get accessToken => _accessToken;
  String? get role => _role;
  int get revision => _revision;

  bool get isAuthenticated {
    return _accessToken != null && _accessToken!.isNotEmpty;
  }

  void saveSession({
    required String accessToken,
    required String role,
  }) {
    _accessToken = accessToken;
    _role = role;
    _revision++;
  }

  void clearSession() {
    _accessToken = null;
    _role = null;
    _revision++;
  }
}
