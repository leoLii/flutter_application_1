import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../shared/layout_utils.dart';
import '../shared/svg_art.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  static const double vw = 553.082989;
  static const double vh = 932.25;

  static const Offset titleBase = Offset(215.48291, 241);
  static const Offset subBase   = Offset(203.48291, 284);

  static const Rect card = Rect.fromLTWH(96.4829, 320, 370, 240);
  static const Size inputSize = Size(338, 44);

  static const Offset emailLabelRel = Offset(20, 24);
  static const Offset emailBoxRel   = Offset(16, 44);
  static const Offset codeLabelRel  = Offset(20, 95);
  static const Offset codeBoxRel    = Offset(16, 114);

  static const Rect innerDividerRel = Rect.fromLTWH(16, 176, 338, 1);
  static const Rect primaryBtnRel   = Rect.fromLTWH(16, 186, 338, 40);

  static const Offset altTipBase = Offset(227.48291, 600);
  static const Rect appleIconBox    = Rect.fromLTWH(207, 618, 28, 28);
  static const Rect facebookIconBox = Rect.fromLTWH(267, 618, 28, 28);
  static const Rect googleIconBox   = Rect.fromLTWH(327, 620, 26, 26);
  static const Offset termsBase     = Offset(177.48291, 668);

  static const Rect backHit = Rect.fromLTWH(86, 33, 33, 28);

  final _emailCtl = TextEditingController();
  final _codeCtl  = TextEditingController();
  final _emailFocus = FocusNode();
  final _codeFocus  = FocusNode();

  bool _emailValid = false;
  bool _sending = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _emailCtl.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtl.dispose();
    _codeCtl.dispose();
    _emailFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    final valid = _validEmail(_emailCtl.text.trim());
    if (valid != _emailValid) setState(() => _emailValid = valid);
  }

  bool _validEmail(String v) {
    final r = RegExp(r'^[\\w\\.\\-]+@([\\w\\-]+\\.)+[a-zA-Z]{2,}$');
    return r.hasMatch(v);
  }

  Future<void> _sendCode() async {
    if (!_emailValid || _sending) return;
    setState(() => _sending = true);
    // TODO: 呼叫後端 API 發送驗證碼
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已發送驗證碼至：${_emailCtl.text.trim()}')),
    );
    _codeFocus.requestFocus();
  }

  void _onLogin() {
    if (!_emailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先輸入正確 Email')),
      );
      _emailFocus.requestFocus();
      return;
    }
    if (_codeCtl.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入驗證碼')),
      );
      _codeFocus.requestFocus();
      return;
    }
    // TODO: 驗證碼登入
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('登入成功（示意）')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const white = Color(0xFFEAF0F6);

    final Rect emailBox = Rect.fromLTWH(
      card.left + emailBoxRel.dx, card.top + emailBoxRel.dy, inputSize.width, inputSize.height);
    final Rect codeBox = Rect.fromLTWH(
      card.left + codeBoxRel.dx, card.top + codeBoxRel.dy, inputSize.width, inputSize.height);

    return Scaffold(
      backgroundColor: const Color(0xFF0C1C24),
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 430 / 932,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: vw, height: vh,
                  child: Stack(
                    children: [
                      Positioned.fill(child: SvgPicture.string(authSvgNoTextsCard240, fit: BoxFit.fill)),
                      box(backHit, Stack(children: [
                        Positioned.fill(child: SvgPicture.string(backArrowPath)),
                        Positioned.fill(child: Material(
                          color: Colors.transparent,
                          child: InkWell(onTap: () => Navigator.of(context).pop()),
                        )),
                      ])),

                      baselineText(
                        titleBase,
                        '登入你的帳號',
                        const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w600, color: white,
                          height: 1.25, leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                      baselineText(
                        subBase,
                        '我們會保護你的資料與隱私',
                        TextStyle(
                          fontSize: 13, color: white.withOpacity(.7),
                          height: 1.25, leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),

                      px(card.topLeft + emailLabelRel, Text('電子郵件',
                        style: TextStyle(fontSize: 12, color: white.withOpacity(.75))),),
                      px(card.topLeft + codeLabelRel, Text('驗證碼',
                        style: TextStyle(fontSize: 12, color: white.withOpacity(.75))),),

                      // Email 輸入
                      _inputBox(emailBox,
                        controller: _emailCtl,
                        focusNode: _emailFocus,
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),

                      // 驗證碼輸入（右側內嵌「發送驗證碼」）
                      _inputBox(
                        codeBox,
                        controller: _codeCtl,
                        focusNode: _codeFocus,
                        hint: '請輸入驗證碼',
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        trailing: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _emailValid ? _sendCode : null,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Text(
                                _sending ? '發送中…' : '發送驗證碼',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _emailValid
                                      ? Colors.white
                                      : Colors.white.withOpacity(.45),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 上方細分隔線（卡片內，不與按鈕重疊）
                      box(Rect.fromLTWH(
                        card.left + innerDividerRel.left,
                        card.top  + innerDividerRel.top,
                        innerDividerRel.width,
                        innerDividerRel.height,
                      ), Container(color: Colors.white.withOpacity(0.24))),

                      // 主按鈕：登入
                      box(Rect.fromLTWH(
                        card.left + primaryBtnRel.left,
                        card.top  + primaryBtnRel.top,
                        primaryBtnRel.width,
                        primaryBtnRel.height,
                      ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: _onLogin,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFA7C7E7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                '登入',
                                style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF143343),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 或使用其他方式登入
                      baselineText(altTipBase, '或使用以下方式登入',
                        TextStyle(fontSize: 12, color: white.withOpacity(.75))),
                      // 三個 Logo
                      box(appleIconBox, SvgPicture.string(appleWhitePath)),
                      box(facebookIconBox, SvgPicture.string(facebookBluePath)),
                      box(googleIconBox, SvgPicture.string(googleGGroup)),

                      // 條款
                      Positioned(
                        left: termsBase.dx, top: termsBase.dy - 14,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 11, color: white.withOpacity(.55), height: 1.25),
                            children: [
                              const TextSpan(text: '登入即表示你同意 '),
                              TextSpan(
                                text: '服務條款',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 1.5,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _showTermsBottomSheet(
                                        context, title: '服務條款', content: _dummyTermsContent),
                              ),
                              const TextSpan(text: ' 與 '),
                              TextSpan(
                                text: '隱私權政策',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 1.5,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _showTermsBottomSheet(
                                        context, title: '隱私權政策', content: _dummyPrivacyContent),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== 版位與輸入元件（AuthPage 專用） =====
  Widget _inputBox(
    Rect box, {
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
    Widget? trailing,
  }) {
    const double horizontal = 12;
    const double trailingReserve = 110;
    return Positioned(
      left: box.left, top: box.top, width: box.width, height: box.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: horizontal)
                  .copyWith(right: horizontal + trailingReserve),
              child: Center(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: keyboardType,
                  maxLength: maxLength,
                  style: const TextStyle(color: Color(0xFFEAF0F6), fontSize: 14),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: hint,
                    hintStyle: const TextStyle(color: Color(0x99EAF0F6), fontSize: 14),
                    isCollapsed: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          if (trailing != null)
            Positioned(
              right: 8, top: 0, bottom: 0,
              child: Align(alignment: Alignment.centerRight, child: trailing),
            ),
        ],
      ),
    );
  }

  static void _showTermsBottomSheet(BuildContext context, {required String title, required String content}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF0F2533),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.45,
          initialChildSize: 0.60,
          maxChildSize: 0.85,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 4, width: 44, margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(title,
                    style: const TextStyle(
                      color: Color(0xFFEAF0F6),
                      fontSize: 18, fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Text(
                        content,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.9),
                          fontSize: 14, height: 1.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA7C7E7),
                        foregroundColor: const Color(0xFF143343),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('我已閱讀', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static const String _dummyTermsContent =
      '這裡是服務條款的示意內容。你可以將正式條款文字替換到這裡。'
      '\n\n1. 使用規範\n2. 帳號與安全\n3. 付費與退款\n4. 責任限制\n5. 其他條款';
  static const String _dummyPrivacyContent =
      '這裡是隱私權政策的示意內容。你可以將正式條款文字替換到這裡。'
      '\n\n- 我們如何收集資料\n- 我們如何使用資料\n- 你的權利\n- 資料保存與刪除\n- 聯絡方式';
}