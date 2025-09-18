import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../shared/layout_utils.dart';
import '../shared/svg_art.dart';
import 'auth_page.dart';
import 'session_page.dart';
import 'conversation_list_page.dart';

class GuestStartPage extends StatelessWidget {
  const GuestStartPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1C24),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            return Stack(
              children: [
                const Positioned.fill(child: _HomeSvgBackground()),
                Positioned(
                  left: w * (364.48291/553.082989),
                  top: h * (26/932.25),
                  width: w * (105/553.082989),
                  height: h * (37/932.25),
                  child: const Center(
                    child: Text('登入 / 註冊',
                        style: TextStyle(fontSize: 14, color: Color(0xFFEAF0F6))),
                  ),
                ),
                Positioned(
                  left: w * (364.48291/553.082989),
                  top: h * (26/932.25),
                  width: w * (105/553.082989),
                  height: h * (37/932.25),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AuthPage()),
                    ),
                  ),
                ),
                Positioned(
                  left: w * (224.48291/553.082989),
                  top: h * (511/932.25),
                  width: w * (105/553.082989),
                  height: h * (45/932.25),
                  child: const Center(
                    child: Text('立即開始',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFEAF0F6))),
                  ),
                ),
                Positioned(
                  left: w * (224.48291/553.082989),
                  top: h * (511/932.25),
                  width: w * (105/553.082989),
                  height: h * (45/932.25),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SessionPage()),
                    ),
                  ),
                ),
                Positioned(
                  left: w * (224/553.082989),
                  top: h * (580/932.25),
                  width: w * (105/553.082989),
                  height: h * (45/932.25),
                  child: const _ConversationListButton(),
                ),
                Positioned(
                  left: w * (235.0/553.082989),
                  top: h * ((589.0-14)/932.25),
                  child: const Text(
                    '你的心情樹洞',
                    style: TextStyle(fontSize: 14, color: Color(0xCCEAF0F6)),
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

class _ConversationListButton extends StatelessWidget {
  const _ConversationListButton();
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA7C7E7),
        foregroundColor: const Color(0xFF143343),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ConversationListPage()),
        );
      },
      child: const Text(
        '對話列表',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
class _HomeSvgBackground extends StatelessWidget {
  const _HomeSvgBackground();
  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(homeSvgHasRobot, fit: BoxFit.fill);
  }
}