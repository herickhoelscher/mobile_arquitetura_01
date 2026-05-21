import 'package:flutter/foundation.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/errors/app_exception.dart';

enum AuthState { initial, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthRemoteDatasource datasource;
  final SessionManager session;

  AuthViewModel({required this.datasource, required this.session});

  AuthState _state = AuthState.initial;
  String _errorMessage = '';
  UserEntity? _profileUser;

  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  UserEntity? get currentUser => session.currentUser;
  UserEntity? get profileUser => _profileUser;
  bool get isLoggedIn => session.isLoggedIn;

  Future<bool> login(String username, String password) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final user = await datasource.login(username, password);
      await session.saveSession(user, user.token);
      _state = AuthState.success;
      notifyListeners();
      return true;
    } on NetworkException {
      _errorMessage = 'Sem conexão com a internet.';
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Erro inesperado. Tente novamente.';
    }

    _state = AuthState.error;
    notifyListeners();
    return false;
  }

  Future<void> loadProfile() async {
    final token = session.token;
    if (token == null) return;

    _state = AuthState.loading;
    notifyListeners();

    try {
      _profileUser = await datasource.getProfile(token);
      _state = AuthState.success;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _state = AuthState.error;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _state = AuthState.error;
    } catch (_) {
      _errorMessage = 'Erro ao carregar perfil.';
      _state = AuthState.error;
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await session.clearSession();
    _profileUser = null;
    _state = AuthState.initial;
    notifyListeners();
  }
}
