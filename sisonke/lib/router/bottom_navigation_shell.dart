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
                        color: Theme.of(context)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.7),
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
                          icon: Icon(Icons.chat_bubble_outline_rounded),
                          selectedIcon: Icon(Icons.chat_bubble_rounded),
                          label: 'Talk',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.spa_outlined),
                          selectedIcon: Icon(Icons.spa_rounded),
                          label: 'Feel',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.diversity_3_outlined),
                          selectedIcon: Icon(Icons.diversity_3_rounded),
                          label: 'Reach',
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
