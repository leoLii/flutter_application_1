import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/conversation_repository.dart';

class ConversationController extends ChangeNotifier {
  final ConversationRepository repo;
  ConversationController(this.repo);

  List<DateTime> days = [];
  Map<DateTime, List<Conversation>> byDay = {};
  StreamSubscription? _sub;

  Future<void> init() async {
    await refreshAll();
    _sub?.cancel();
    _sub = repo.watchChanges().listen((_) => refreshAll());
  }

  Future<void> refreshAll() async {
    final allDays = await repo.allDaysAsc();
    days = allDays;
    byDay = {};
    for (final d in days) {
      byDay[d] = await repo.listByDay(d);
    }
    notifyListeners();
  }

  Future<Conversation> create(String title) async {
    final c = await repo.create(title);
    await refreshAll();
    return c;
  }

  Future<void> addMessage(int convId, String text, {required bool fromUser}) async {
    await repo.addMessage(convId, text, fromUser: fromUser);
  }

  Future<void> deleteConv(int id) async {
    await repo.deleteConversation(id);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}