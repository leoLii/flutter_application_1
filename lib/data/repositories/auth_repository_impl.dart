import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_auth_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalAuthDataSource local;
  AuthRepositoryImpl(this.local);

  @override
  Future<bool> isLoggedIn() => local.isLoggedIn();

  @override
  Future<void> login({required String email, required String password}) async {
    // TODO: 接后端校验；现在先本地通过
    await local.setLoggedIn(true, email: email);
  }

  @override
  Future<void> logout() => local.setLoggedIn(false);

  @override
  Future<String?> currentEmail() => local.currentEmail();
}
