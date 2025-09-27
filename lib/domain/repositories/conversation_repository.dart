import '../entities/conversation.dart';

abstract class ConversationRepository {
  Future<List<DateTime>> allDaysAsc();
  Future<List<Conversation>> listByDay(DateTime dayKey);
  Stream<void> watchChanges();
  Future<Conversation> create(String title);
  Future<void> addMessage(int convId, String text, {required bool fromUser});
  Future<void> deleteConversation(int convId);
}