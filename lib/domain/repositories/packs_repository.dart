import '../entities/packs.dart';

abstract class PacksRepository {
  Future<Packs> load();
  Future<Packs> setPacks(int packs);
  Future<Packs> addPacks(int delta);
}