import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// import '../shared/layout_utils.dart';
import '../shared/svg_art.dart';

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
    if (_listening) {
      _stt.stop();
    }
    _scrollCtl.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (_started) return; // 防止重複啟動
    setState(() {
      _started = true;
      _secLeft = _totalSeconds; // 每次啟動從 60 秒開始
    });

    _ctrl
      ..reset()
      ..forward();
    _flow
      ..reset()
      ..repeat();

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) return;
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
        // 允許之後再次開始新一輪 1 分鐘窗口
        _started = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('時間到')),
          );
        }
      }
    });
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

      // 3) 若仍無中文，嘗試常見別名（有些裝置不在列表卻能接受）
      pick ??= ['zh-CN','zh_CN','zh-Hans','cmn-Hans-CN','zh-TW','zh_TW','zh-Hant','yue-Hant-HK']
          .firstWhere((id) => true, orElse: () => '');

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
        setState(() => _transcript = r.recognizedWords);
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
  }

  void _onSttStatus(String s) {
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            // === 相對比例（基於你原設計尺寸換算） ===
            const backLeftFrac   = 86.0 / 553.082989;  // 86 = 62+24
            const backTopFrac    = 24.0 / 932.25;
            const backWFrac      = 33.0 / 553.082989;
            const backHFrac      = 28.0 / 932.25;

            const micWFrac       = 140.0 / 553.082989;
            const micHFrac       = 140.0 / 932.25;
            const micLeftFrac    = ((553.082989 - 140.0) / 2) / 553.082989;
            const micTopFrac     = ((932.25 - 140.0) / 2) / 932.25;

            const listLeftFrac   = 16.0 / 553.082989;
            const listRightFrac  = 16.0 / 553.082989;
            const listTopFrac    = 96.0 / 932.25;
            const listBottomFrac = 180.0 / 932.25;

            const subtitleLeftFrac   = 24.0 / 553.082989;
            const subtitleRightFrac  = 24.0 / 553.082989;
            const subtitleBottomFrac = 70.0 / 932.25;

            const timerBottomFrac = 10.0 / 932.25;
            const bubbleMaxWFrac  = 360.0 / 553.082989;

            return Stack(
              children: [
                // 最底層：純藍天空底色
                const Positioned.fill(
                  child: ColoredBox(color: Color(0xFF1E88E5)),
                ),

                // 先畫 SVG
                Positioned.fill(
                  child: SvgPicture.string(
                    sessionSvgWrapped,
                    fit: BoxFit.fill,
                  ),
                ),

                // 彩雲背景：多個會流動的橙色雲團
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

                        // 使用實際螢幕 w/h 做定位與半徑
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

                // 返回按鈕（相對定位替代 box(backHit, ...)）
                Positioned(
                  left: w * backLeftFrac,
                  top:  h * backTopFrac,
                  width:  w * backWFrac,
                  height: h * backHFrac,
                  child: Stack(children: [
                    Positioned.fill(child: SvgPicture.string(backArrowPath)),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(onTap: () => Navigator.of(context).pop()),
                      ),
                    ),
                  ]),
                ),

                // 對話紀錄（滾動列表）
                Positioned(
                  left:   w * listLeftFrac,
                  right:  w * listRightFrac,
                  top:    h * listTopFrac,
                  bottom: h * listBottomFrac,
                  child: IgnorePointer(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: ListView.builder(
                        controller: _scrollCtl,
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: _messages.length + (_transcript.isNotEmpty ? 1 : 0),
                        itemBuilder: (context, idx) {
                          final isLive = idx == _messages.length && _transcript.isNotEmpty;
                          final text = isLive ? _transcript : _messages[idx];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: w * bubbleMaxWFrac),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: isLive ? const Color(0xFFFF8A00).withOpacity(0.55) : const Color(0xFFFF8A00),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Text(
                                      text,
                                      style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.35),
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
                ),

                // 中央大型錄音按鈕（相對尺寸/位置）
                Positioned(
                  left: w * micLeftFrac,
                  top:  h * micTopFrac,
                  width:  w * micWFrac,
                  height: h * micHFrac,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleRecord,
                      borderRadius: BorderRadius.circular(80),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: _listening ? const Color(0xFFE65100) : const Color(0xFFA7C7E7),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_listening ? const Color(0xFFE65100) : const Color(0xFFA7C7E7)).withOpacity(0.5),
                              blurRadius: 24,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _listening ? Icons.stop_rounded : Icons.mic_rounded,
                            size: 64,
                            color: const Color(0xFF143343),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 辨識文字顯示（置中，倒數上方）
                Positioned(
                  left:   w * subtitleLeftFrac,
                  right:  w * subtitleRightFrac,
                  bottom: h * subtitleBottomFrac,
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _transcript.isEmpty ? 0.0 : 1.0,
                      child: Text(
                        _transcript,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                // 底部倒數計時
                Positioned(
                  left: 0, right: 0, bottom: h * timerBottomFrac,
                  child: SafeArea(
                    top: false,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '剩餘時間  ${_mmss(_secLeft)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}