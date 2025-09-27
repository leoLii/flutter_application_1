import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/packs_controller.dart';

import 'auth.dart';
import 'session.dart';
import 'conversation_list.dart';
import 'user_profile.dart';

class GuestStartPage extends StatelessWidget {
  const GuestStartPage({super.key});

  void _promptLogin(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (d) => AlertDialog(
        backgroundColor: const Color(0xFF0F2533),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('需要登入', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        content: const Text('請先登入才能開始對話。', style: TextStyle(color: Colors.white70, height: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(d);
              Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const AuthPage()));
            },
            child: const Text('去登入'),
          ),
        ],
      ),
    );
  }

  Future<void> _startSession(BuildContext context) async {
    final auth  = context.read<AuthController>();
    final packs = context.read<PacksController>();

    if (!auth.loggedIn) {
      _promptLogin(context);
      return;
    }

    if (packs.packs30 <= 0) {
      // 次數不足 → 引導到個人頁購買
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0F2533),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('次數不足', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          content: const Text('目前沒有可用的 30 分鐘套餐，是否前往個人頁面購買？', style: TextStyle(color: Colors.white70, height: 1.4)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('知道了'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserProfilePage()));
              },
              child: const Text('去購買'),
            ),
          ],
        ),
      );
      return;
    }

    // 有次數，允許進入會話
    // ignore: use_build_context_synchronously
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SessionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth  = context.watch<AuthController>();
    final packs = context.watch<PacksController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0C1C24),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final paddingH = w * 0.08;        // 橫向留白
            final gap = h * 0.02;             // 元素間距
            final btnHeightPrimary = h * 0.072;
            final btnHeightSecondary = h * 0.06;
            final fsTitle = h * 0.022;
            final fsBody  = h * 0.018;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 頂部：登入/註冊 或 User Profile
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        if (auth.loggedIn) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const UserProfilePage()),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AuthPage()),
                          );
                        }
                      },
                      child: Text(
                        auth.loggedIn ? 'User Profile' : '登入 / 註冊',
                        style: TextStyle(
                          color: const Color(0xFFEAF0F6),
                          fontSize: fsBody,
                        ),
                      ),
                    ),
                  ),

                  // 中上方顯示機器人圖片
                  Padding(
                    padding: EdgeInsets.only(top: h * 0.04, bottom: h * 0.02),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/robot.svg',
                        width: w * 0.4,
                        fit: BoxFit.contain,
                        semanticsLabel: 'Robot',
                        placeholderBuilder: (_) => SizedBox(
                          width: w * 0.1,
                          height: w * 0.1,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),

                  // 套餐剩餘顯示（在頂部展示）
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: EdgeInsets.only(top: h * 0.004, bottom: h * 0.008),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF102431),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        '剩餘套餐：${packs.packs30}',
                        style: const TextStyle(color: Color(0xFFEAF0F6), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  // 中間：主操作區域
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: w * 0.76),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 主按鈕：立即開始（需要已登入 + 有套餐）
                            SizedBox(
                              height: btnHeightPrimary,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA7C7E7),
                                  foregroundColor: const Color(0xFF143343),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(h * 0.016),
                                  ),
                                ),
                                onPressed: () => auth.loggedIn ? _startSession(context) : _promptLogin(context),
                                child: Text(
                                  '立即開始',
                                  style: TextStyle(
                                    fontSize: fsTitle,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: gap),

                            // 次按鈕：對話列表
                            SizedBox(
                              height: btnHeightSecondary,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFA7C7E7), width: 1.4),
                                  foregroundColor: const Color(0xFFA7C7E7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(h * 0.014),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const ConversationListPage()),
                                  );
                                },
                                child: Text(
                                  '對話列表',
                                  style: TextStyle(
                                    fontSize: fsBody,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 底部：標語
                  Padding(
                    padding: EdgeInsets.only(bottom: h * 0.02),
                    child: Text(
                      '你的心情樹洞',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xCCEAF0F6),
                        fontSize: fsBody,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}