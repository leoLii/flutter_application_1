import 'package:isar/isar.dart';
part 'db_models.g.dart';

@collection
class ConversationDb {
  Id id = Isar.autoIncrement;
  late String title;
  String lastMessage = '';
  DateTime updatedAt = DateTime.now();
  int messageCount = 0;

  @Index()
  late DateTime dayKey; // 日期索引
}

@collection
class MessageDb {
  Id id = Isar.autoIncrement;
  late int conversationId;
  @Index()
  late DateTime createdAt;
  @Index(type: IndexType.hash)
  late String text;
  bool fromUser = true;
}