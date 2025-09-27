import 'package:flutter/foundation.dart';
import '../../domain/entities/packs.dart';
import '../../domain/repositories/packs_repository.dart';

class PacksController extends ChangeNotifier {
  final PacksRepository repo;
  Packs _packs = const Packs(0);

  Packs get state => _packs;
  int get packs30 => _packs.packs30;
  int get totalMinutes => _packs.totalMinutes;

  PacksController(this.repo);

  Future<void> init() async {
    _packs = await repo.load();
    notifyListeners();
  }

  Future<void> addPacks(int n) async {
    _packs = await repo.addPacks(n);
    notifyListeners();
  }

  /// 按分鐘扣（四捨五入到 30 分鐘套餐）
  Future<bool> tryConsumeMinutes(int minutes) async {
    if (minutes <= 0) return true;
    final needPacks = (minutes + 29) ~/ 30;
    if (_packs.packs30 < needPacks) return false;
    _packs = await repo.addPacks(-needPacks);
    notifyListeners();
    return true;
  }

  Future<void> setPacks(int v) async {
    _packs = await repo.setPacks(v);
    notifyListeners();
  }
}