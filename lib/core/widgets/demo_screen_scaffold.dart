import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DemoScreenScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBackButton;
  final String fallbackRoute;

  const DemoScreenScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBackButton = true,
    this.fallbackRoute = '/',
  });

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(fallbackRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: showBackButton ? 56 : 0,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _handleBack(context),
              )
            : null,
        title: Text(title),
        centerTitle: false,
        titleSpacing: showBackButton ? 0 : 16,
        actions: actions,
      ),
      body: SafeArea(child: body),
    );
  }
}
