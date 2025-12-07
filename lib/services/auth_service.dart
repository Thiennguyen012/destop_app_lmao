import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static int? _currentUserId;
  static String? _currentUserEmail;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  static int? get currentUserId => _currentUserId;
  static String? get currentUserEmail => _currentUserEmail;

  Future<bool> register(String email, String password, String name) async {
    try {
      final db = DatabaseHelper();
      await db.registerUser(email, password, name);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final db = DatabaseHelper();
      final user = await db.loginUser(email, password);

      if (user != null) {
        _currentUserId = user['id'];
        _currentUserEmail = user['email'];

        // Lưu vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', user['id']);
        await prefs.setString('userEmail', user['email']);

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentUserId = null;
    _currentUserEmail = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userEmail');
  }

  Future<void> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getInt('userId');
    _currentUserEmail = prefs.getString('userEmail');
  }

  bool isLoggedIn() {
    return _currentUserId != null;
  }
}
