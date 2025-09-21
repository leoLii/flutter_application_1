import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const _loggedKey = 'logged_in';
  static const _emailKey  = 'email';

  /// 读取是否已登录
  static Future<bool> isLoggedIn() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_loggedKey) ?? false;
  }

  /// 保存登录状态
  static Future<void> setLoggedIn(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_loggedKey, value);
  }

  /// 保存/读取邮箱
  static Future<void> setEmail(String email) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_emailKey, email);
  }

  static Future<String?> getEmail() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_emailKey);
  }

  /// 退出登录
  static Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_loggedKey);
    await sp.remove(_emailKey);
  }
}