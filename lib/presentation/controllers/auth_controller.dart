import 'package:flutter/foundation.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repo;
  bool _loggedIn = false;
  String? _email;

  AuthController(this.repo);

  bool get loggedIn => _loggedIn;
  String? get email => _email;

  Future<void> init() async {
    _loggedIn = await repo.isLoggedIn();
    _email = await repo.currentEmail();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await repo.login(email: email, password: password);
    await init();
  }

  Future<void> logout() async {
    await repo.logout();
    await init();
  }
}