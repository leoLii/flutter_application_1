import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthDataSource {
  static const _kLoggedIn = 'logged_in';
  static const _kEmail    = 'email';

  Future<bool> isLoggedIn() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kLoggedIn) ?? false;
    }
  Future<void> setLoggedIn(bool v, {String? email}) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kLoggedIn, v);
    if (email != null) await sp.setString(_kEmail, email);
    if (!v) await sp.remove(_kEmail);
  }
  Future<String?> currentEmail() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kEmail);
  }
}