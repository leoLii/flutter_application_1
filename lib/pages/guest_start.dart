import 'package:flutter/material.dart';
import 'auth.dart';
import 'session.dart';
import 'conversation_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_profile.dart';
import '../services/packs_manager.dart';

class GuestStartPage extends StatefulWidget {
  const GuestStartPage({super.key});

  @override
  State<GuestStartPage> createState() => _GuestStartPageState();
}

class _GuestStartPageState extends State<GuestStartPage> {
  Future<bool> _isLoggedIn() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool('logged_in') ?? false;
  }

  @override
  void initState() {
    super.initState();
    // 初始化套餐管理器並監聽變化
    PacksManager.I.init();
    PacksManager.I.addListener(_onPacksChanged);
  }

  void _onPacksChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    PacksManager.I.removeListener(_onPacksChanged);
    super.dispose();
  }

  void _startSession(BuildContext context) {
    final packs = PacksManager.I.packs30;
    if (packs <= 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF0F2533),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('次數不足', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          content: const Text('目前沒有可用的 30 分鐘套餐，請先前往個人頁面購買。', style: TextStyle(color: Colors.white70, height: 1.4)),
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SessionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1C24),
      body: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final loggedIn = snap.data == true;
          final packs = PacksManager.I.packs30;

          // 顯示首頁，但右上角依登入狀態切換為「User Profile」或「登入 / 註冊」
          return SafeArea(
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
                            if (loggedIn) {
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
                            loggedIn ? 'User Profile' : '登入 / 註冊',
                            style: TextStyle(
                              color: const Color(0xFFEAF0F6),
                              fontSize: fsBody,
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
                            '剩餘套餐：$packs',
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
                                // 主按鈕：立即開始（若無次數則彈窗提示）
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
                                    onPressed: () => _startSession(context),
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
          );
        },
      ),
    );
  }
}