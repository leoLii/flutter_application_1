abstract class AuthRepository {
  Future<bool> isLoggedIn();
  Future<void> login({required String email, required String password});
  Future<void> logout();
  Future<String?> currentEmail();
}