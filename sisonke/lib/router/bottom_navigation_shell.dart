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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
              : Container(
                  key: const ValueKey('bottom-nav'),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1916) : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? const Color(0xFF332A24)
                            : const Color(0xFFF2E7DC),
                        width: 1.1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: NavigationBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      height: 68,
                      selectedIndex: navigationShell.currentIndex,
                      indicatorColor: const Color(0xFFFF7A3D).withValues(alpha: 0.16),
                      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                      onDestinationSelected: (int index) {
                        navigationShell.goBranch(
                          index,
                          initialLocation: index == navigationShell.currentIndex,
                        );
                      },
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home_rounded, color: Color(0xFFFF7A3D)),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.chat_bubble_outline_rounded),
                          selectedIcon: Icon(Icons.chat_bubble_rounded, color: Color(0xFFFF7A3D)),
                          label: 'Talk',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.spa_outlined),
                          selectedIcon: Icon(Icons.spa_rounded, color: Color(0xFFFF7A3D)),
                          label: 'Check-in',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.diversity_3_outlined),
                          selectedIcon: Icon(Icons.diversity_3_rounded, color: Color(0xFFFF7A3D)),
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
