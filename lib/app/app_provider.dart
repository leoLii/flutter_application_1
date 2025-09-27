import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'di.dart';

class AppProviders extends StatelessWidget {
  final Widget child;
  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: DI.auth),
        ChangeNotifierProvider.value(value: DI.packs),
      ],
      child: child,
    );
  }
}