import 'package:flutter/material.dart';

import 'routes.dart';
import '../core/theme/app_theme.dart';

class KMartApp extends StatelessWidget {
  const KMartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'K Mart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRoutes.router,
    );
  }
}
