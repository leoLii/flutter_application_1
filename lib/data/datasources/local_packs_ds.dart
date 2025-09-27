import 'package:shared_preferences/shared_preferences.dart';

class LocalPacksDataSource {
  static const _kPacks30 = 'packs_30';
  Future<int> load() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getInt(_kPacks30) ?? 0;
  }
  Future<int> set(int v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kPacks30, v < 0 ? 0 : v);
    return v < 0 ? 0 : v;
  }
}