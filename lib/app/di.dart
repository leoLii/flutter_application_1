import '../data/datasources/local_auth_ds.dart';
import '../data/datasources/local_packs_ds.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/packs_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/packs_repository.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/controllers/packs_controller.dart';

class DI {
  // data sources
  static final _authLocal  = LocalAuthDataSource();
  static final _packsLocal = LocalPacksDataSource();

  // repos
  static final AuthRepository  authRepo  = AuthRepositoryImpl(_authLocal);
  static final PacksRepository packsRepo = PacksRepositoryImpl(_packsLocal);

  // controllers
  static final AuthController  auth  = AuthController(authRepo);
  static final PacksController packs = PacksController(packsRepo);

  static Future<void> init() async {
    await Future.wait([auth.init(), packs.init()]);
  }
}