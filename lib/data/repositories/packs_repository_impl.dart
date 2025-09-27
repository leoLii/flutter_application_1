import '../../domain/entities/packs.dart';
import '../../domain/repositories/packs_repository.dart';
import '../datasources/local_prefs.dart';

class PacksRepositoryImpl implements PacksRepository {
  final LocalPrefs _prefs = LocalPrefs.instance;

  @override
  Future<Packs> load() async {
    final n = await _prefs.getPacks30();
    return Packs(n);
  }

  @override
  Future<Packs> setPacks(int packs) async {
    await _prefs.setPacks30(packs);
    final n = await _prefs.getPacks30();
    return Packs(n);
  }

  @override
  Future<Packs> addPacks(int delta) async {
    final n = await _prefs.addPacks30(delta);
    return Packs(n);
  }
}