import 'package:isar/isar.dart';
import '../../domain/entities/conversation.dart' as domain;
import '../../domain/repositories/conversation_repository.dart';
import '../datasources/local_db.dart';
import '../models/db_models.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  @override
  Future<List<DateTime>> allDaysAsc() async {
    final isar = await LocalDb.instance();
    return isar.conversationDbs
        .where()
        .sortByDayKey()
        .distinctByDayKey()
        .dayKeyProperty()
        .findAll();
  }

  @override
  Future<List<domain.Conversation>> listByDay(DateTime dayKey) async {
    final isar = await LocalDb.instance();
    final list = await isar.conversationDbs
        .filter()
        .dayKeyEqualTo(DateTime(dayKey.year, dayKey.month, dayKey.day))
        .sortByUpdatedAtDesc()
        .findAll();
    return list.map(_toDomain).toList();
  }

  @override
  Stream<void> watchChanges() async* {
    final isar = await LocalDb.instance();
    yield* isar.conversationDbs.watchLazy();
  }

  @override
  Future<domain.Conversation> create(String title) async {
    final isar = await LocalDb.instance();
    final now = DateTime.now();
    final conv = ConversationDb()
      ..title = title
      ..updatedAt = now
      ..dayKey = DateTime(now.year, now.month, now.day);
    await isar.writeTxn(() async => await isar.conversationDbs.put(conv));
    return _toDomain(conv);
  }

  @override
  Future<void> addMessage(int convId, String text, {required bool fromUser}) async {
    final isar = await LocalDb.instance();
    final now = DateTime.now();
    await isar.writeTxn(() async {
      final msg = MessageDb()
        ..conversationId = convId
        ..text = text
        ..fromUser = fromUser
        ..createdAt = now;
      await isar.messageDbs.put(msg);

      final conv = await isar.conversationDbs.get(convId);
      if (conv != null) {
        conv.lastMessage = text;
        conv.updatedAt = now;
        conv.messageCount += 1;
        conv.dayKey = DateTime(now.year, now.month, now.day);
        await isar.conversationDbs.put(conv);
      }
    });
  }

  @override
  Future<void> deleteConversation(int convId) async {
    final isar = await LocalDb.instance();
    await isar.writeTxn(() async {
      await isar.messageDbs.filter().conversationIdEqualTo(convId).deleteAll();
      await isar.conversationDbs.delete(convId);
    });
  }

  domain.Conversation _toDomain(ConversationDb c) => domain.Conversation(
        id: c.id,
        title: c.title,
        lastMessage: c.lastMessage,
        updatedAt: c.updatedAt,
        messageCount: c.messageCount,
      );
}