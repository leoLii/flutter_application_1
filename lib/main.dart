import 'package:flutter/material.dart';
import 'app/app_provider.dart';
import 'app/di.dart';
import 'presentation/pages/guest_start.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DI.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp(
        home: const GuestStartPage(),
      ),
    );
  }
}