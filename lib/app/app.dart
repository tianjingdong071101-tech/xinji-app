import 'package:flutter/material.dart';
import 'router.dart';
import '../core/theme/app_theme.dart';

class XinjiApp extends StatelessWidget {
  const XinjiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '心迹',
      debugShowCheckedModeBanner: false,
      theme: XinjiTheme.dark,
      routerConfig: routerProvider,
    );
  }
}
