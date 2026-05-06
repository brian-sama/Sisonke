import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationShell extends StatelessWidget {
  final Widget child;
  final StatefulNavigationShell navigationShell;

  const BottomNavigationShell({
    super.key,
    required this.child,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (context.canPop()) {
          context.pop();
          return;
        }

        if (navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isKeyboardVisible
              ? const SizedBox.shrink(key: ValueKey('keyboard-hidden-nav'))
              : DecoratedBox(
                  key: const ValueKey('bottom-nav'),
                  decoration: BoxDecoration(
                    color: Theme.of(context).navigationBarTheme.backgroundColor,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: NavigationBar(
                      selectedIndex: navigationShell.currentIndex,
                      labelBehavior:
                          NavigationDestinationLabelBehavior.alwaysShow,
                      onDestinationSelected: (int index) {
                        navigationShell.goBranch(
                          index,
                          initialLocation:
                              index == navigationShell.currentIndex,
                        );
                      },
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home_rounded),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.smart_toy_outlined),
                          selectedIcon: Icon(Icons.smart_toy_rounded),
                          label: 'Friend',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.favorite_border_rounded),
                          selectedIcon: Icon(Icons.favorite_rounded),
                          label: 'Check-In',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.groups_outlined),
                          selectedIcon: Icon(Icons.groups_rounded),
                          label: 'Community',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.support_agent_outlined),
                          selectedIcon: Icon(Icons.support_agent_rounded),
                          label: 'Support',
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
