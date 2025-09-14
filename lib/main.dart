import 'package:flutter/material.dart';
import 'pages/guest_start_page.dart';

void main() => runApp(const PsycheApp());

class PsycheApp extends StatelessWidget {
  const PsycheApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '心理諮商 App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const GuestStartPage(),
    );
  }
}