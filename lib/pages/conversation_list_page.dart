import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 簡單對話資料模型（可之後抽到 data/models.dart）
class Conversation {
  final String id;
  String title;
  String lastMessage;
  DateTime updatedAt;
  int messageCount;

  Conversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    required this.messageCount,
  });
}

/// 對話列表頁
/// - 可直接使用，也可透過傳入 initialConversations 與回調接上你的資料層
class ConversationListPage extends StatefulWidget {
  const ConversationListPage({
    super.key,
    this.initialConversations,
    this.onOpenConversation,
    this.onCreateConversation,
    this.onDeleteConversation,
  });

  /// 初始資料（不傳則用示例資料）
  final List<Conversation>? initialConversations;

  /// 點擊項目時的回調（未提供時，預設彈出提示）
  final void Function(Conversation conv)? onOpenConversation;

  /// 點擊右下角新增時回調（未提供時，頁面會本地新增一筆示例）
  final Conversation Function()? onCreateConversation;

  /// 左滑刪除時回調（未提供時，本地刪除）
  final void Function(Conversation conv)? onDeleteConversation;

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  final List<Conversation> _items = <Conversation>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  void _bootstrap() async {
    // 先用傳入的資料；若無則造幾筆假資料方便視覺確認
    final seed = widget.initialConversations ?? _demoSeed();
    _items
      ..clear()
      ..addAll(seed..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
    setState(() => _loading = false);
  }

  List<Conversation> _demoSeed() {
    final now = DateTime.now();
    return List.generate(4, (i) {
      return Conversation(
        id: 'demo_${i + 1}',
        title: '對話 ${i + 1}',
        lastMessage: i == 0
            ? '歡迎回來，點擊開始新的 1 分鐘對話'
            : '這是歷史訊息摘要…',
        updatedAt: now.subtract(Duration(minutes: i * 7 + 2)),
        messageCount: math.max(1, 3 - i),
      );
    });
  }

  String _fmtTime(DateTime t) {
    final d = t;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(d.year, d.month, d.day);
    final isToday = today == thatDay;
    if (isToday) {
      final hh = d.hour.toString().padLeft(2, '0');
      final mm = d.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  }

  void _open(Conversation c) {
    if (widget.onOpenConversation != null) {
      widget.onOpenConversation!(c);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('打開對話：${c.title} (id=${c.id})')),
    );
  }

  void _create() {
    Conversation c;
    if (widget.onCreateConversation != null) {
      c = widget.onCreateConversation!();
    } else {
      final n = _items.length + 1;
      c = Conversation(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        title: '新的對話 $n',
        lastMessage: '（開始說話後會出現訊息）',
        updatedAt: DateTime.now(),
        messageCount: 0,
      );
    }
    setState(() {
      _items.insert(0, c);
    });
    _open(c);
  }

  void _delete(Conversation c) {
    if (widget.onDeleteConversation != null) {
      widget.onDeleteConversation!(c);
    }
    setState(() {
      _items.removeWhere((e) => e.id == c.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFEAF0F6);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Scaffold(
            backgroundColor: const Color(0xFF0C1C24),
            appBar: AppBar(
              backgroundColor: const Color(0xFF0C1C24),
              elevation: 0,
              title: const Text('對話', style: TextStyle(color: white, fontWeight: FontWeight.w700)),
              actions: [
                IconButton(
                  onPressed: _bootstrap,
                  icon: const Icon(Icons.refresh, color: white),
                  tooltip: '重新整理',
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: const Color(0xFFA7C7E7),
              foregroundColor: const Color(0xFF143343),
              onPressed: _create,
              icon: const Icon(Icons.add_comment),
              label: const Text('新對話'),
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? _emptyView(context)
                    : RefreshIndicator(
                        onRefresh: () async => _bootstrap(),
                        color: const Color(0xFFA7C7E7),
                        backgroundColor: const Color(0xFF0C1C24),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final c = _items[index];
                            return Dismissible(
                              key: ValueKey(c.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) => _delete(c),
                              child: _ConversationTile(
                                title: c.title,
                                subtitle: c.lastMessage,
                                trailing: _fmtTime(c.updatedAt),
                                count: c.messageCount,
                                onTap: () => _open(c),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        );
      },
    );
  }

  Widget _emptyView(BuildContext context) {
    const white = Color(0xFFEAF0F6);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, color: white.withOpacity(.6), size: 56),
            const SizedBox(height: 12),
            Text(
              '還沒有任何對話',
              style: TextStyle(color: white.withOpacity(.9), fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              '點右下角「新對話」開始 1 分鐘語音對話並自動轉文字。',
              textAlign: TextAlign.center,
              style: TextStyle(color: white.withOpacity(.7), fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.count,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFEAF0F6);
    return Material(
      color: const Color(0xFF143343).withOpacity(0.16),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFA7C7E7),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.mic_rounded, color: Color(0xFF143343)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          trailing,
                          style: TextStyle(color: white.withOpacity(.65), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: white.withOpacity(.85), fontSize: 13, height: 1.2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Badge(text: '$count'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8A00),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
