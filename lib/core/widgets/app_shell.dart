import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sincro/core/widgets/app_drawer.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({
    required this.child,
    super.key,
  });

  static const double _appBarHeight = 100.0;
  static const double _logoHeight = 50.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(_appBarHeight),
        child: Container(
          height: _appBarHeight,
          decoration: BoxDecoration(
            color:
                Theme.of(context).appBarTheme.backgroundColor ??
                Theme.of(context).primaryColor,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: SafeArea(
            left: true,
            right: true,
            top: true,
            bottom: false,
            child: Row(
              children: [
                Container(
                  width: _logoHeight + 48.0,
                  height: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                  ),
                  child: Image.asset(
                    'assets/images/app_bar_logo.png',
                    height: _logoHeight,
                    fit: BoxFit.contain,
                  ),
                ),
                const Expanded(child: SizedBox()),
                Container(
                  height: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                    right: 24.0,
                  ),
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                        ),
                        iconSize: 32.0,
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).openAppDrawerTooltip,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      endDrawer: const AppDrawer(),
      body: child,
    );
  }
}
