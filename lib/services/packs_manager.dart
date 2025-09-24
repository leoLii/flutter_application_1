import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局的 30 分鐘套餐管理器
/// - 單例：PacksManager.I
/// - 持久化鍵：'packs_30'
class PacksManager extends ChangeNotifier {
  PacksManager._();
  static final PacksManager I = PacksManager._();

  static const _kKey = 'packs_30';

  bool _inited = false;
  int _packs30 = 0;

  /// 初始化（只會執行一次）
  Future<void> init() async {
    if (_inited) return;
    final sp = await SharedPreferences.getInstance();
    _packs30 = sp.getInt(_kKey) ?? 0;
    _inited = true;
    notifyListeners();
  }

  /// 目前剩餘 30 分鐘套餐數
  int get packs30 => _packs30;

  /// 換算成總分鐘
  int get totalMinutes => _packs30 * 30;

  /// 設置套餐數（會覆蓋）
  Future<void> setPacks(int v) async {
    _packs30 = v < 0 ? 0 : v;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kKey, _packs30);
    notifyListeners();
  }

  /// 增加 n 份套餐（可為負，負數等同扣減）
  Future<void> addPacks(int n) async {
    await setPacks(_packs30 + n);
  }

  /// （可選擴展）嘗試消耗指定分鐘數，成功返回 true
  Future<bool> tryConsumeMinutes(int minutes) async {
    if (minutes <= 0) return true;
    final needPacks = (minutes + 29) ~/ 30; // 以 30 分鐘為粒度扣
    if (_packs30 < needPacks) return false;
    await addPacks(-needPacks);
    return true;
  }
}