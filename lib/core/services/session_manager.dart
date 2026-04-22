/// Manajer sesi sederhana (in-memory) untuk menyimpan
/// JWT token dan data profil user yang sedang login.
///
/// Pada production, sebaiknya gunakan `shared_preferences` atau
/// `flutter_secure_storage` untuk persistensi.
class SessionManager {
  // Singleton
  SessionManager._internal();
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;

  // ── Data Sesi ─────────────────────────────────
  String? _accessToken;
  Map<String, dynamic>? _currentUser;

  // ── Token ─────────────────────────────────────
  String? get accessToken => _accessToken;

  void setToken(String token) {
    _accessToken = token;
  }

  bool get isLoggedIn => _accessToken != null;

  // ── User Profile ──────────────────────────────
  Map<String, dynamic>? get currentUser => _currentUser;

  void setUser(Map<String, dynamic> user) {
    _currentUser = user;
  }

  String get userName => _currentUser?['full_name'] ?? _currentUser?['username'] ?? 'User';
  String get userEmail => _currentUser?['email'] ?? '';
  String get username => _currentUser?['username'] ?? '';
  int get userId => _currentUser?['id'] ?? 0;

  // ── Logout ────────────────────────────────────
  void clear() {
    _accessToken = null;
    _currentUser = null;
  }
}
