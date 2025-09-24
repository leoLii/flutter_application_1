import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // ===== Timeline & grouping state =====
  late DateTime _todayDate;                 // yyyy-MM-dd (no time)
  late List<DateTime> _days;               // timeline days from today going back
  int _timelineIndex = 0;                  // 0 = today
  final ScrollController _stackCtl = ScrollController(); // for future use (if scrollable content)
  final ScrollController _mainScroll = ScrollController(); // 跨日滾動
  final Map<DateTime, GlobalKey> _sectionKeys = <DateTime, GlobalKey>{}; // 每日段落定位
  late DateTime _minDay; // 最早有資料的日期（去時分秒）
  late DateTime _maxDay; // 最晚有資料的日期（去時分秒）
  Map<DateTime, List<Conversation>> _byDay = <DateTime, List<Conversation>>{};

  DateTime _dateKey(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get _selectedDate => _days[_timelineIndex];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  void _bootstrap() async {
    final seed = widget.initialConversations ?? _demoSeed();
    _items
      ..clear()
      ..addAll(seed..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));

    _rebuildGroups();

    // 依據資料決定日期範圍：從第一筆（最早）到最後一筆（最晚）
    if (_items.isNotEmpty) {
      final allDays = _items.map((e) => _dateKey(e.updatedAt)).toList();
      allDays.sort((a, b) => a.compareTo(b));
      _minDay = allDays.first;
      _maxDay = allDays.last;
      final total = _maxDay.difference(_minDay).inDays + 1;
      _days = List.generate(total, (i) => _minDay.add(Duration(days: i)));
      _timelineIndex = _days.length - 1; // 起始停留在第一天（第一個保存的卡片那天）
    } else {
      final today = _dateKey(DateTime.now());
      _minDay = today;
      _maxDay = today;
      _days = [today];
      _timelineIndex = _days.length - 1;
    }

    setState(() => _loading = false);
  }

  void _rebuildGroups() {
    final map = <DateTime, List<Conversation>>{};
    for (final c in _items) {
      final k = _dateKey(c.updatedAt);
      (map[k] ??= <Conversation>[]).add(c);
    }
    // 每日內由新到舊
    map.forEach((k, v) => v.sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
    _byDay = map;
  }

  void _ensureMoreDays(int needBeyond) {
    // 已不再需要無限延展
  }

  List<Conversation> _demoSeed() {
    final now = DateTime.now();
    final rng = math.Random(42);
    final List<Conversation> list = [];
    for (int d = 0; d < 10; d++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: d));
      final perDay = 1 + rng.nextInt(3); // 每天 1~3 筆
      for (int i = 0; i < perDay; i++) {
        final t = day.add(Duration(hours: rng.nextInt(23), minutes: rng.nextInt(59)));
        list.add(Conversation(
          id: 'demo_${d}_${i}',
          title: '對話 ${d + 1}-${i + 1}',
          lastMessage: i == 0 && d == 0 ? '歡迎回來，點擊開始新的 1 分鐘對話' : '這是歷史訊息摘要…',
          updatedAt: t,
          messageCount: 1 + rng.nextInt(6),
        ));
      }
    }
    return list;
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

  void _jumpToDay(int idx) {
    if (idx < 0 || idx >= _days.length) return;
    setState(() => _timelineIndex = idx);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _sectionKeys[_days[idx]];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          alignment: 0.05, // 對齊到頂部附近
        );
      }
    });
  }

  void _onScrollUpdate(ScrollMetrics m) {
    // 根據最接近頂部的日期標題，更新當前所屬日期索引
    // 遍歷少量 key，找出和螢幕頂端距離最小的
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    double bestDy = double.infinity;
    int bestIdx = _timelineIndex;
    for (var i = 0; i < _days.length; i++) {
      final key = _sectionKeys[_days[i]];
      final ctx = key?.currentContext;
      if (ctx == null) continue;
      final rb = ctx.findRenderObject() as RenderBox?;
      if (rb == null) continue;
      final dy = rb.localToGlobal(Offset.zero).dy; // 與螢幕頂端距離
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
              ],
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n is ScrollUpdateNotification) {
                        _onScrollUpdate(n.metrics);
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
                              // 回到今天
                              TextButton.icon(
                                onPressed: () {
                                  final idx = _days.indexOf(_maxDay);
                                  if (idx != -1) _jumpToDay(idx);
                                },
                                style: TextButton.styleFrom(foregroundColor: const Color(0xFFEAF0F6)),
                                icon: const Icon(Icons.today_outlined),
                                label: const Text('今天'),
                              ),
                              const SizedBox(width: 8),
                              // 刻度式滑桿（0=今天 → 越大越早）
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
                                    max: (_days.length - 1).toDouble(),
                                    divisions: _days.length - 1,
                                    value: _timelineIndex.clamp(0, _days.length - 1).toDouble(),
                                    onChanged: (v) => _jumpToDay(v.round()),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 當前日期顯示
                              Builder(
                                builder: (_) {
                                  final d = _selectedDate;
                                  final txt = DateFormat('yyyy/MM/dd (EEE)').format(d);
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
                        for (final day in _days) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              key: _sectionKeys.putIfAbsent(day, () => GlobalKey()),
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                              child: Text(
                                DateFormat('yyyy/MM/dd EEE').format(day),
                                style: const TextStyle(color: Color(0xFFEAF0F6), fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                              child: _DayStack(
                                conversations: _byDay[day] ?? const <Conversation>[],
                                onOpen: _open,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _DayStack extends StatelessWidget {
  const _DayStack({required this.conversations, required this.onOpen});
  final List<Conversation> conversations;
  final void Function(Conversation) onOpen;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final cardH = h * 0.18;         // 卡片高度（相對）
    final gap = cardH * 0.42;       // 堆疊間距（重疊）
    final n = conversations.length;
    final stackH = n == 0 ? h * 0.2 : cardH + (n - 1) * gap;

    if (n == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: const Center(
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StackCard extends StatelessWidget {
  const _StackCard({required this.conv, required this.elevation, required this.onTap});
  final Conversation conv;
  final double elevation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFEAF0F6);
    return Material(
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
                    DateFormat('HH:mm').format(conv.updatedAt),
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
    );
  }
}
