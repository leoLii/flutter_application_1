import '../../domain/entities/packs.dart';
import '../../domain/repositories/packs_repository.dart';
import '../datasources/local_packs_ds.dart';

class PacksRepositoryImpl implements PacksRepository {
  final LocalPacksDataSource local;
  PacksRepositoryImpl(this.local);

  @override
  Future<Packs> load() async => Packs(await local.load());

  @override
  Future<Packs> setPacks(int packs) async => Packs(await local.set(packs));

  @override
  Future<Packs> addPacks(int delta) async {
    final cur = await local.load();
    return setPacks(cur + delta);
  }
}