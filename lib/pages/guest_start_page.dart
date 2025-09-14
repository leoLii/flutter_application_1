import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../shared/layout_utils.dart';
import '../shared/svg_art.dart';
import 'auth_page.dart';
import 'session_page.dart';

class GuestStartPage extends StatelessWidget {
  const GuestStartPage({super.key});

  static const double vw = 553.082989;
  static const double vh = 932.25;

  static const Rect btnLogin = Rect.fromLTWH(364.48291, 26, 105, 37);
  static const Rect btnStart = Rect.fromLTWH(224.48291, 511, 105, 45);
  static const double tagX = 235.0;
  static const double tagY = 589.0;

  @override
  Widget build(BuildContext context) {
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
                      Positioned.fill(child: SvgPicture.string(homeSvgHasRobot, fit: BoxFit.fill)),
                      box(btnLogin, const Center(
                        child: Text('登入 / 註冊',
                          style: TextStyle(fontSize: 14, color: Color(0xFFEAF0F6))),
                      )),
                      box(btnLogin, GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AuthPage()),
                        ),
                      )),
                      box(btnStart, const Center(
                        child: Text('立即開始',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFEAF0F6))),
                      )),
                      box(btnStart, GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SessionPage()),
                        ),
                      )),
                      const Positioned(
                        left: tagX, top: tagY - 14,
                        child: Text('你的心情樹洞',
                          style: TextStyle(fontSize: 14, color: Color(0xCCEAF0F6))),
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
}