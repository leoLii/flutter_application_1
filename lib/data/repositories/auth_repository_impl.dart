import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_prefs.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalPrefs _prefs = LocalPrefs.instance;

  @override
  Future<bool> isLoggedIn() => _prefs.getLoggedIn();

  @override
  Future<void> login({required String email, required String password}) async {
    // TODO: 接后端校验；现在先本地通过
    await _prefs.setLoggedIn(true);
    await _prefs.setEmail(email);
  }

  @override
  Future<void> logout() async {
    await _prefs.clearAuth();
  }

  @override
  Future<String?> currentEmail() => _prefs.getEmail();
}
