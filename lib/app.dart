import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';

class RedHawkWalletApp extends StatelessWidget {
  const RedHawkWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeNotifier.instance,
      builder: (context, themeMode, _) {
        return MaterialApp.router(
          title: 'RedHawk Wallet',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
