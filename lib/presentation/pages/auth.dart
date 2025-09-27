import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/controllers/auth_controller.dart';
import 'guest_start.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailCtl = TextEditingController();
  final _codeCtl = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _codeCtl.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (_submitting) return;
    final email = _emailCtl.text.trim();
    final password = _codeCtl.text;

    setState(() => _submitting = true);
    try {
      // 使用全局 AuthController
      final auth = context.read<AuthController>();
      await auth.login(email, password);
      if (!mounted) return;
      if (auth.loggedIn) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const GuestStartPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登入失敗，請檢查帳號或密碼')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登入發生錯誤：$e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final pX = w * 0.08;
    final fsTitle = h * 0.026;
    final fsBody = h * 0.02;
    final inputH = h * 0.06;
    final btnH = h * 0.065;

    return Scaffold(
      backgroundColor: const Color(0xFF0C1C24),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: pX),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              SizedBox(height: h * 0.02),
              Text(
                '登入',
                style: TextStyle(
                  fontSize: fsTitle,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: h * 0.01),
              Text(
                '使用測試帳號登入（帳號與密碼皆為 test）',
                style: TextStyle(fontSize: fsBody, color: Colors.white70),
              ),
              SizedBox(height: h * 0.04),
              // Email
              Text('電子郵件', style: TextStyle(fontSize: fsBody, color: Colors.white70)),
              SizedBox(height: h * 0.01),
              SizedBox(
                height: inputH,
                child: TextField(
                  controller: _emailCtl,
                  style: TextStyle(color: Colors.white, fontSize: fsBody),
                  decoration: InputDecoration(
                    hintText: 'test',
                    hintStyle: TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFF0F2533),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white.withOpacity(.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white.withOpacity(.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFA7C7E7)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: h * 0.02),
              // Password
              Text('密碼', style: TextStyle(fontSize: fsBody, color: Colors.white70)),
              SizedBox(height: h * 0.01),
              SizedBox(
                height: inputH,
                child: TextField(
                  controller: _codeCtl,
                  obscureText: _obscure,
                  style: TextStyle(color: Colors.white, fontSize: fsBody),
                  decoration: InputDecoration(
                    hintText: 'test',
                    hintStyle: TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: const Color(0xFF0F2533),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white.withOpacity(.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white.withOpacity(.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFA7C7E7)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: btnH,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA7C7E7),
                    foregroundColor: const Color(0xFF143343),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submitting ? null : _onLogin,
                  child: _submitting
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('登入', style: TextStyle(fontSize: fsBody, fontWeight: FontWeight.w700)),
                ),
              ),
              SizedBox(height: h * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}