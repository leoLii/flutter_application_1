import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../data/datasources/local_auth_ds.dart';
import '../data/datasources/local_packs_ds.dart';
import '../data/datasources/local_db.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/packs_repository_impl.dart';
import '../data/repositories/conversation_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/packs_repository.dart';
import '../domain/repositories/conversation_repository.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/controllers/packs_controller.dart';
import '../presentation/controllers/conversation_controller.dart';

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

  // conversation
  static final ConversationRepository conversationRepo = ConversationRepositoryImpl();
  static final ConversationController conversation = ConversationController(conversationRepo);

  static Future<void> init() async {
    // 初始化 zh_TW 日期格式，避免 LocaleDataException
    try {
      await initializeDateFormatting('zh_TW', null);
      Intl.defaultLocale = 'zh_TW';
    } catch (_) {
      // 如果初始化失败则忽略，DateFormat 将使用系统默认
    }
    await Future.wait([
      auth.init(),
      packs.init(),
    ]);
    await conversation.init();
  }
}