import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/auth_manager.dart';
import 'guest_start_page.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthManager.getEmail(),
      builder: (context, snap) {
        final email = snap.data ?? '';
        final size = MediaQuery.of(context).size;
        final h = size.height;
        final s = math.min(size.width, h);
        final fsTitle = h * 0.022;
        final fsBody  = h * 0.018;
        final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';

        return Scaffold(
          backgroundColor: const Color(0xFF0C1C24),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        iconSize: h * 0.028,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: s * 0.1,
                    backgroundColor: const Color(0xFFA7C7E7),
                    child: Text(initial,
                        style: TextStyle(
                          fontSize: s * 0.08,
                          color: const Color(0xFF143343),
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  SizedBox(height: h * 0.02),
                  Text(
                    email.isEmpty ? '未綁定郵箱' : email,
                    style: TextStyle(fontSize: fsTitle, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: h * 0.01),
                  Text('已登入', style: TextStyle(fontSize: fsBody, color: Colors.white70)),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: h * 0.06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA7C7E7),
                        foregroundColor: const Color(0xFF143343),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await AuthManager.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const GuestStartPage()),
                            (route) => false,
                          );
                        }
                      },
                      child: Text('退出登入', style: TextStyle(fontSize: fsBody, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}