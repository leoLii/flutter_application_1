import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/conversation_controller.dart';
import '../../domain/entities/conversation.dart' as domain;

/// 對話列表頁（Isar + Controller 版本）
class ConversationListPage extends StatefulWidget {
  const ConversationListPage({super.key});

  @override
  State<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends State<ConversationListPage> {
  // 視圖狀態（與資料無關）
  final ScrollController _mainScroll = ScrollController();
  final Map<DateTime, GlobalKey> _sectionKeys = <DateTime, GlobalKey>{};
  int _timelineIndex = 0; // 0 = 最早；會根據 days 長度調整
  bool _scrollTickScheduled = false;

  DateTime _dateKey(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    // 若未初始化，這裡不強行調用 init（在 DI.init() 中做）；
    // 但首次進頁可手動 refresh 一次，避免空白
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ctl = context.read<ConversationController>();
      if (ctl.days.isEmpty) {
        await ctl.refreshAll();
        if (!mounted) return;
        _resetTimelineIndex();
      } else {
        _resetTimelineIndex();
      }
    });
  }

  @override
  void dispose() {
    _mainScroll.dispose();
    super.dispose();
  }

  void _resetTimelineIndex() {
    final ctl = context.read<ConversationController>();
    if (ctl.days.isEmpty) {
      setState(() => _timelineIndex = 0);
      return;
    }
    // 停在最新一天（最後一個）
    setState(() => _timelineIndex = ctl.days.length - 1);
  }

  Future<void> _bootstrap() async {
    await context.read<ConversationController>().refreshAll();
    if (!mounted) return;
    _resetTimelineIndex();
  }

  void _open(domain.Conversation c) {
    // 這裡保留提示；接 SessionPage 可在此跳轉
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('打開對話：${c.title} (id=${c.id})')),
    );
  }

  Future<void> _create() async {
    final ctl = context.read<ConversationController>();
    final n = ctl.days.fold<int>(0, (p, d) => p + (ctl.byDay[d]?.length ?? 0)) + 1;
    final c = await ctl.create('新的對話 $n');
    if (!mounted) return;
    _open(c);
  }

  Future<void> _delete(domain.Conversation c) async {
    await context.read<ConversationController>().deleteConv(c.id);
  }

  void _jumpToDay(int idx) {
    final ctl = context.read<ConversationController>();
    final days = ctl.days;
    if (idx < 0 || idx >= days.length) return;
    setState(() => _timelineIndex = idx);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _sectionKeys[days[idx]];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          alignment: 0.05,
        );
      }
    });
  }

  void _scheduleScrollUpdate() {
    if (_scrollTickScheduled) return;
    _scrollTickScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollTickScheduled = false;
      _updateCurrentDayByViewport();
    });
  }

  void _updateCurrentDayByViewport() {
    final ctl = context.read<ConversationController>();
    final days = ctl.days;
    if (days.isEmpty) return;
    double bestDy = double.infinity;
    int bestIdx = _timelineIndex;
    for (var i = 0; i < days.length; i++) {
      final key = _sectionKeys[days[i]];
      final ctx = key?.currentContext;
      if (ctx == null) continue;
      final rb = ctx.findRenderObject() as RenderBox?;
      if (rb == null) continue;
      final dy = rb.localToGlobal(Offset.zero).dy;
      final dist = (dy - kToolbarHeight).abs();
      if (dist < bestDy) {
        bestDy = dist;
        bestIdx = i;
      }
    }
    if (bestIdx != _timelineIndex) {
      setState(() => _timelineIndex = bestIdx);
    }
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
    return DateFormat('yyyy/MM/dd', 'zh_TW').format(d);
  }

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFEAF0F6);
    final ctl = context.watch<ConversationController>();
    final days = ctl.days;
    final byDay = ctl.byDay;

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
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: white),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: '返回',
              ),
              title: const Text('對話', style: TextStyle(color: white, fontWeight: FontWeight.w700)),
              actions: [
                IconButton(
                  onPressed: _bootstrap,
                  icon: const Icon(Icons.refresh, color: white),
                  tooltip: '重新整理',
                ),
                IconButton(
                  onPressed: _create,
                  icon: const Icon(Icons.add, color: white),
                  tooltip: '新對話',
                ),
              ],
            ),
            body: days.isEmpty
                ? const _EmptyState()
                : RefreshIndicator(
                    color: Colors.white,
                    backgroundColor: const Color(0xFF143343),
                    onRefresh: _bootstrap,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n is ScrollUpdateNotification) {
                          _scheduleScrollUpdate();
                        }
                        return false;
                      },
                      child: CustomScrollView(
                        controller: _mainScroll,
                        slivers: [
                          // 置頂工具欄：今天快捷 + 滑桿（刻度式） + 當前日期
                          SliverAppBar(
                            pinned: true,
                            backgroundColor: const Color(0xFF0C1C24),
                            elevation: 0,
                            toolbarHeight: 56,
                            title: Row(
                              children: [
                                // 回到今天（最新一天）
                                TextButton.icon(
                                  onPressed: () {
                                    final idx = days.length - 1;
                                    if (idx >= 0) _jumpToDay(idx);
                                  },
                                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFEAF0F6)),
                                  icon: const Icon(Icons.today_outlined),
                                  label: const Text('今天'),
                                ),
                                const SizedBox(width: 8),
                                // 刻度式滑桿（0 = 最早 → 越大越新）
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 2.5,
                                      tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 1.5),
                                      activeTickMarkColor: Colors.white54,
                                      inactiveTickMarkColor: Colors.white24,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                    ),
                                    child: Slider(
                                      min: 0,
                                      max: (days.length - 1).toDouble(),
                                      divisions: days.length > 1 ? days.length - 1 : null,
                                      value: _timelineIndex.clamp(0, days.length - 1).toDouble(),
                                      onChanged: (v) => _jumpToDay(v.round()),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // 當前日期顯示（本地化 zh_TW）
                                Builder(
                                  builder: (_) {
                                    final d = days[_timelineIndex.clamp(0, days.length - 1)];
                                    final txt = DateFormat('yyyy/MM/dd (EEE)', 'zh_TW').format(d);
                                    return Text(
                                      txt,
                                      style: const TextStyle(color: Color(0xFFEAF0F6), fontSize: 12, fontWeight: FontWeight.w600),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          // 跨日堆疊 section：每個日期一塊
                          for (final day in days) ...[
                            SliverToBoxAdapter(
                              child: Padding(
                                key: _sectionKeys.putIfAbsent(day, () => GlobalKey()),
                                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                                child: Text(
                                  DateFormat('yyyy/MM/dd EEE', 'zh_TW').format(day),
                                  style: const TextStyle(color: Color(0xFFEAF0F6), fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                                child: _DayStack(
                                  conversations: byDay[day] ?? const <domain.Conversation>[],
                                  onOpen: _open,
                                  onDelete: _delete,
                                  fmtTime: _fmtTime,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _DayStack extends StatelessWidget {
  const _DayStack({
    required this.conversations,
    required this.onOpen,
    required this.onDelete,
    required this.fmtTime,
  });
  final List<domain.Conversation> conversations;
  final void Function(domain.Conversation) onOpen;
  final void Function(domain.Conversation) onDelete;
  final String Function(DateTime) fmtTime;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final cardH = h * 0.18;         // 卡片高度（相對）
    final gap = cardH * 0.42;       // 堆疊間距（重疊）
    final n = conversations.length;
    final stackH = n == 0 ? h * 0.2 : cardH + (n - 1) * gap;

    if (n == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('該日沒有對話', style: TextStyle(color: Color(0xFFEAF0F6))),
        ),
      );
    }

    return SingleChildScrollView(
      reverse: true, // 往上翻
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        height: stackH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (int i = 0; i < n; i++)
              Positioned(
                top: (n - 1 - i) * gap, // 最近的在最上
                left: 0,
                right: 0,
                height: cardH,
                child: _StackCard(
                  conv: conversations[i],
                  elevation: 6.0 + i * 1.0,
                  onTap: () => onOpen(conversations[i]),
                  onDelete: () => onDelete(conversations[i]),
                  fmtTime: fmtTime,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StackCard extends StatelessWidget {
  const _StackCard({
    required this.conv,
    required this.elevation,
    required this.onTap,
    required this.onDelete,
    required this.fmtTime,
  });
  final domain.Conversation conv;
  final double elevation;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String Function(DateTime) fmtTime;

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFEAF0F6);
    return Dismissible(
      key: ValueKey('conv_${conv.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: const Color(0xFFB00020),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Material(
        color: const Color(0xFF143343).withOpacity(0.16),
        elevation: elevation,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        conv.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fmtTime(conv.updatedAt),
                      style: TextStyle(color: white.withOpacity(.7), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    conv.lastMessage,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: white.withOpacity(.9), fontSize: 13, height: 1.3),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.mic_rounded, size: 18, color: Color(0xFFA7C7E7)),
                    const SizedBox(width: 6),
                    Text('${conv.messageCount}', style: TextStyle(color: white.withOpacity(.9), fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Color(0xFFA7C7E7)),
          const SizedBox(height: 12),
          const Text('還沒有任何對話', style: TextStyle(color: Color(0xFFEAF0F6), fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('點擊右上角「新對話」開始', style: TextStyle(color: Color(0x99EAF0F6))),
        ],
      ),
    );
  }
}