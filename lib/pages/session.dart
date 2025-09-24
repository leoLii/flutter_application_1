import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/packs_manager.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> with TickerProviderStateMixin {

  // ===== 背景顏色動畫（隨機混合流動，藍→橘逐步過渡）與 1 分鐘倒數 =====
  late final AnimationController _ctrl; // 進度（0→1，控制藍→橘比例）
  late final AnimationController _flow; // 流動相位（循環）
  static const int _totalSeconds = 60; // 1 分鐘
  int _secLeft = _totalSeconds;
  Timer? _ticker;
  bool _started = false;
  bool _paused = false; // 是否暫停對話（暫停倒計時與錄音）
  final List<double> _seeds = List<double>.generate(6, (i) => (i + 1) * 0.173); // 流動用相位偏移

  // 語音識別
  late final stt.SpeechToText _stt;
  bool _listening = false;
  String _transcript = '';
  // 語言偏好：中文（若裝置不支援會在初始化時自動回退）
  String _localeId = 'zh_CN';

  // 對話紀錄（每段話）
  final List<String> _messages = <String>[];
  final ScrollController _scrollCtl = ScrollController();
  final ScrollController _overlayCtl = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 60));
    _flow = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _stt = stt.SpeechToText();
    // 注意：不在這裡 forward/repeat，待點擊後啟動
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _flow.dispose();
    _ctrl.dispose();
    try { _stt.stop(); } catch (_) {}
    try { _stt.cancel(); } catch (_) {}
    _scrollCtl.dispose();
    _overlayCtl.dispose();
    super.dispose();
  }
  void _scrollOverlayToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_overlayCtl.hasClients) {
        _overlayCtl.animateTo(
          _overlayCtl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted || _paused) return; // 暫停時不遞減
      setState(() {
        _secLeft = (_secLeft > 0) ? _secLeft - 1 : 0;
      });
      if (_secLeft == 0) {
        t.cancel();
        _ticker = null;
        _ctrl.stop();
        _flow.stop();
        if (_transcript.trim().isNotEmpty) {
          _commitCurrentUtterance();
        }
        if (_listening) {
          try { await _stt.stop(); } catch (_) {}
          setState(() => _listening = false);
        }
        _started = false;
        // 消耗 1 分鐘（從 30 分鐘套餐中以分鐘粒度扣），失敗則不動
        await PacksManager.I.tryConsumeMinutes(1);
        if (mounted) {
          setState(() {}); // 觸發 UI 刷新剩餘分鐘/套餐
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('時間到，已扣除 1 分鐘')),
          );
        }
      }
    });
  }

  void _startCountdown() {
    if (_started) return; // 防止重複啟動
    setState(() {
      _started = true;
      _paused = false;
      _secLeft = _totalSeconds; // 每次啟動從 60 秒開始
    });

    _ctrl
      ..reset()
      ..forward();
    _flow
      ..reset()
      ..repeat();

    _startTicker();
  }

  Future<void> _togglePause() async {
    if (!_started) return; // 未開始無需暫停
    setState(() => _paused = !_paused);
    if (_paused) {
      // 暫停：停止錄音與動畫（保留剩餘秒）
      _flow.stop();
      if (_listening) {
        try { await _stt.stop(); } catch (_) {}
        setState(() => _listening = false);
      }
    } else {
      // 繼續：恢復動畫與錄音（若窗口仍有效）
      _flow.repeat();
      if (_secLeft > 0 && !_listening) {
        _resumeIfWindowActive();
      }
      // 計時器在暫停時未遞減，這裡確保存在
      if (_ticker == null) {
        _startTicker();
      }
    }
  }

  /// Robustly pick a Chinese locale (prefer Simplified, fallback to Traditional, then default).
  Future<String> _chooseChineseLocaleOrFallback() async {
    try {
      final locales = await _stt.locales();
      String norm(String x) => x.toLowerCase().replaceAll('_', '-');
      String? pick;
      // 1) 強優先：簡體
      for (final l in locales) {
        final id = norm(l.localeId);
        if (id.contains('zh') && (id.contains('cn') || id.contains('hans'))) {
          pick = l.localeId; break;
        }
      }
      // 2) 次優先：繁體（台/港/zh-Hant）
      pick ??= locales.firstWhere(
        (l) {
          final id = norm(l.localeId);
          return id.contains('zh') && (id.contains('tw') || id.contains('hk') || id.contains('hant'));
        },
        orElse: () => stt.LocaleName('', ''),
      ).localeId;


      if (pick.isNotEmpty) return pick;
    } catch (_) {}
    // 4) 兜底返回預設簡體
    return 'zh-CN';
  }

  Future<void> _toggleRecord() async {
    if (!_listening) {
      final available = await _stt.initialize(
        onStatus: _onSttStatus,
        onError: (e) => _onSttError(e),
      );
      if (!available) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('無法啟用語音（裝置或權限不支援）')),
        );
        return;
      }
      // 可靠選擇中文語系（簡體優先，失敗則繁體，再失敗兜底 zh-CN）
      _localeId = await _chooseChineseLocaleOrFallback();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('語音識別語言：$_localeId')),
      );
      setState(() {
        _listening = true;
        _transcript = '';
      });
      // 開始 1 分鐘對話窗口（倒數與彩雲）
      _startCountdown();
      await _beginListen();
    } else {
      await _stopRecording();
      _commitCurrentUtterance();
    }
  }

  Future<void> _stopRecording() async {
    if (_listening) {
      try {
        await _stt.stop();
      } catch (_) {}
      setState(() => _listening = false);
    }
  }

  Future<void> _beginListen() async {
    await _stt.listen(
      onResult: (r) {
        if (!mounted) return; // widget 已被移除，忽略回調
        if (!mounted) return;
        setState(() => _transcript = r.recognizedWords);
        _scrollOverlayToEnd();
        if (r.finalResult) {
          _commitCurrentUtterance();
          if (_secLeft > 0) {
            _resumeIfWindowActive();
          }
        }
      },
      listenMode: stt.ListenMode.dictation,
      partialResults: true,                 // 邊說邊顯示
      cancelOnError: true,
      pauseFor: const Duration(milliseconds: 2800), // 停頓 ≥ 2.8s 才算結束，降低過度敏感
      listenFor: const Duration(seconds: 60),       // 上限 1 分鐘
      localeId: _localeId,                          // 強制中文識別
      onSoundLevelChange: null,                     // 不用額外敏感度
    );
  }

  void _resumeIfWindowActive() {
    if (_secLeft <= 0) return;
    // 略延遲避免立刻重入
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted || _secLeft <= 0) return;
      if (!_listening) {
        _stt.initialize(onStatus: _onSttStatus, onError: (e) => _onSttError(e)).then((ok) {
          if (ok && mounted) {
            // 每次續聽時也確保使用中文語系
            () async { _localeId = await _chooseChineseLocaleOrFallback(); }();
            setState(() => _listening = true);
            _beginListen();
          }
        });
      }
    });
  }

  void _commitCurrentUtterance() {
    final text = _transcript.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(text);
      _transcript = '';
    });
    // 滾動到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtl.hasClients) {
        _scrollCtl.animateTo(
          _scrollCtl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
    _scrollOverlayToEnd();
  }

  void _onSttStatus(String s) {
    if (!mounted) return;
    // speech_to_text 狀態回調
    if (s == 'notListening') {
      setState(() => _listening = false);
      // 若在對話窗口內且有暫存文字，先提交
      if (_transcript.trim().isNotEmpty) {
        _commitCurrentUtterance();
      }
      // 窗口未結束則自動續聽（輕微延遲防抖）
      if (_secLeft > 0) {
        Future.delayed(const Duration(milliseconds: 250), _resumeIfWindowActive);
      }
    }
  }

  void _onSttError(dynamic e) {
    if (!mounted) return;
    final msg = (e is Exception) ? e.toString() : '$e';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('語音錯誤：$msg')),
    );
  }

  String _mmss(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1C24),
      body: Stack(
        children: [
          // === 背景：放在 SafeArea 之外，真正全屏鋪滿 ===
          const Positioned.fill(
            child: ColoredBox(color: Color(0xFF1E88E5)),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_ctrl, _flow]),
              builder: (_, __) {
                final t = _ctrl.value;                   // 0→1：橙色覆蓋比例逐漸增多
                final phase = _flow.value * 2 * math.pi; // 流動相位

                const cloudOrange = Color(0xFFFF8A00);
                final blobs = <Widget>[];
                for (var i = 0; i < _seeds.length; i++) {
                  final seed = _seeds[i];
                  final baseX = 0.5 + 0.45 * math.sin(phase * (0.6 + 0.1 * i) + seed * 8.0);
                  final baseY = 0.5 + 0.35 * math.cos(phase * (0.5 + 0.07 * i) + seed * 6.0);

                  final minR = 0.14; // 相對於畫面短邊
                  final maxR = 0.34;
                  final radius = (minR + (maxR - minR) * (0.35 + 0.65 * t));
                  final alpha = (0.30 + 0.55 * t).clamp(0.0, 0.85);

                  // 使用 MediaQuery 尺寸，確保背景不受 SafeArea 影響
                  final size = MediaQuery.of(context).size;
                  final w = size.width;
                  final h = size.height;
                  final cx = w * baseX;
                  final cy = h * baseY;
                  final r  = math.min(w, h) * radius;

                  blobs.add(
                    Positioned(
                      left: cx - r,
                      top: cy - r,
                      width: r * 2,
                      height: r * 2,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                cloudOrange.withOpacity(alpha),
                                cloudOrange.withOpacity(0.0),
                              ],
                              stops: const [0.0, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return Stack(children: blobs);
              },
            ),
          ),

          // === 前景內容：放在 SafeArea 之內，避免被瀏海/手勢區遮擋 ===
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                // 相對尺寸（文字、間距、圓角、圖示等）
                final s = math.min(w, h);
                final fsBody     = h * (15.0 / 932.25);
                final fsSubtitle = h * (16.0 / 932.25);
                final fsTimer    = h * (14.0 / 932.25);
                final padX       = s * (12.0 / 553.082989);
                final padY       = s * (8.0  / 553.082989);
                final bubbleR    = s * (12.0 / 553.082989);
                final iconSize   = h * (64.0 / 932.25);
                final blurR      = s * (24.0 / 553.082989);
                final spreadR    = s * (6.0  / 553.082989);

                const bubbleMaxWFrac  = 360.0 / 553.082989;
                const micSizeFrac     = 140.0 / 553.082989; // 以寬為準

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 頂部：返回 + DEBUG 扣 1 組
                      Row(
                        children: [
                          SizedBox(
                            width: w * 0.10,
                            height: h * 0.05,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: h * 0.028,
                                  ),
                                ),
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => Navigator.of(context).pop(),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              if (PacksManager.I.packs30 <= 0) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('沒有可扣的套餐')),
                                );
                                return;
                              }
                              await PacksManager.I.addPacks(-1);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('DEBUG：已扣除 1 組（30 分鐘）')),
                              );
                            },
                            child: const Text('DEBUG-扣1組', style: TextStyle(color: Colors.white70)),
                          ),
                        ],
                      ),

                      SizedBox(height: h * 0.01),

                      // 中部：對話列表（向下擠壓）
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ListView.builder(
                            controller: _scrollCtl,
                            padding: EdgeInsets.only(bottom: h * (12.0 / 932.25)),
                            itemCount: _messages.length + (_transcript.isNotEmpty ? 1 : 0),
                            itemBuilder: (context, idx) {
                              final isLive = idx == _messages.length && _transcript.isNotEmpty;
                              final text = isLive ? _transcript : _messages[idx];
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: h * 0.006),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: w * bubbleMaxWFrac),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: isLive ? const Color(0xFFFF8A00).withOpacity(0.55) : const Color(0xFFFF8A00),
                                        borderRadius: BorderRadius.circular(bubbleR),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: padX, vertical: padY),
                                        child: Text(
                                          text,
                                          style: TextStyle(color: Colors.white, fontSize: fsBody, height: 1.35),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // 中間透明流式對話框（顯示我的對話內容，無限流式）
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 220),
                        opacity: (_listening || _transcript.isNotEmpty) ? 1.0 : 0.0,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: w * 0.86,
                              minWidth: w * 0.6,
                              maxHeight: h * 0.26,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withOpacity(0.28), width: 1),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: padX, vertical: padY),
                                child: Scrollbar(
                                  thumbVisibility: false,
                                  controller: _overlayCtl,
                                  child: SingleChildScrollView(
                                    controller: _overlayCtl,
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ..._messages.take(_messages.length).skip((_messages.length - 6).clamp(0, _messages.length)).map((m) => Padding(
                                              padding: EdgeInsets.only(bottom: h * 0.006),
                                              child: Text(
                                                m,
                                                style: TextStyle(color: Colors.white.withOpacity(0.86), fontSize: fsBody, height: 1.35),
                                              ),
                                            )),
                                        if (_transcript.isNotEmpty || _listening)
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  _transcript.isEmpty ? '…' : _transcript,
                                                  style: TextStyle(color: Colors.white, fontSize: fsSubtitle, height: 1.35, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                              AnimatedBuilder(
                                                animation: _flow,
                                                builder: (_, __) {
                                                  final show = (_flow.value % 1.0) < 0.5;
                                                  return Opacity(
                                                    opacity: show ? 1.0 : 0.0,
                                                    child: Text('▋', style: TextStyle(color: Colors.white, fontSize: fsSubtitle)),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.012),

                      // 暫停/繼續控制 + 暫停時顯示剩餘（本次 + 帳戶）
                      Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: h * 0.05,
                              child: TextButton.icon(
                                onPressed: _togglePause,
                                icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white),
                                label: Text(_paused ? '繼續對話' : '暫停對話', style: TextStyle(color: Colors.white, fontSize: fsBody)),
                              ),
                            ),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 220),
                              opacity: _paused ? 1.0 : 0.0,
                              child: Padding(
                                padding: EdgeInsets.only(top: h * 0.004),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: padX, vertical: padY * 0.9),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.38),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '本次剩餘 ${_mmss(_secLeft)}',
                                        style: TextStyle(color: Colors.white, fontSize: fsTimer, fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: h * 0.004),
                                      Text(
                                        '帳戶剩餘 ${PacksManager.I.totalMinutes} 分鐘',
                                        style: TextStyle(color: Colors.white70, fontSize: fsTimer * 0.9),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: h * 0.008),

                      // 中央錄音按鈕
                      Center(
                        child: SizedBox(
                          width: w * micSizeFrac,
                          height: w * micSizeFrac,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _toggleRecord,
                              borderRadius: BorderRadius.circular((w * micSizeFrac) / 2),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOut,
                                decoration: BoxDecoration(
                                  color: _listening ? const Color(0xFFE65100) : const Color(0xFFA7C7E7),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_listening ? const Color(0xFFE65100) : const Color(0xFFA7C7E7)).withOpacity(0.5),
                                      blurRadius: blurR,
                                      spreadRadius: spreadR,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    _listening ? Icons.stop_rounded : Icons.mic_rounded,
                                    size: iconSize,
                                    color: const Color(0xFF143343),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.012),

                      // 底部倒數計時
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: padX, vertical: padY),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '剩餘時間  ${_mmss(_secLeft)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fsTimer,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: h * 0.01),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}