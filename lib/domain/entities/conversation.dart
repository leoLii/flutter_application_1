class Conversation {
  final int id;                 // 对应 Isar 的 Id
  final String title;
  final String lastMessage;
  final DateTime updatedAt;
  final int messageCount;

  Conversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    required this.messageCount,
  });
}