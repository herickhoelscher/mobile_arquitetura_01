import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/entities/user_entity.dart';

class SessionManager {
  static const _keyToken = 'auth_token';
  static const _keyUserId = 'auth_user_id';
  static const _keyUsername = 'auth_username';
  static const _keyFirstName = 'auth_first_name';
  static const _keyLastName = 'auth_last_name';
  static const _keyEmail = 'auth_email';
  static const _keyImage = 'auth_image';

  UserEntity? _currentUser;
  String? _token;

  UserEntity? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _currentUser != null;

  Future<void> saveSession(UserEntity user, String token) async {
    _currentUser = user;
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setInt(_keyUserId, user.id);
    await prefs.setString(_keyUsername, user.username);
    await prefs.setString(_keyFirstName, user.firstName);
    await prefs.setString(_keyLastName, user.lastName);
    await prefs.setString(_keyEmail, user.email);
    await prefs.setString(_keyImage, user.image);
  }

  Future<bool> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_keyToken);
    if (savedToken == null) return false;

    _token = savedToken;
    _currentUser = UserEntity(
      id: prefs.getInt(_keyUserId) ?? 0,
      username: prefs.getString(_keyUsername) ?? '',
      firstName: prefs.getString(_keyFirstName) ?? '',
      lastName: prefs.getString(_keyLastName) ?? '',
      email: prefs.getString(_keyEmail) ?? '',
      image: prefs.getString(_keyImage) ?? '',
    );
    return true;
  }

  Future<void> clearSession() async {
    _currentUser = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyFirstName);
    await prefs.remove(_keyLastName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyImage);
  }
}
