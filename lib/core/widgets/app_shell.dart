import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/widgets/app_drawer.dart';
import 'package:sincro/core/widgets/app_logo.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const Padding(
          padding: EdgeInsets.all(12.0),
          child: AppLogo(),
        ),
        title: const Text(''),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: child,
    );
  }
}
