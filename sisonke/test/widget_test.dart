import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sisonke/router/bottom_navigation_shell.dart';

void main() {
  testWidgets('navigation shell exposes the four primary destinations', (
    WidgetTester tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => BottomNavigationShell(
            navigationShell: navigationShell,
            child: navigationShell,
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/home', builder: (_, _) => const SizedBox()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/talk', builder: (_, _) => const SizedBox()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/feel', builder: (_, _) => const SizedBox()),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/reach', builder: (_, _) => const SizedBox()),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Talk'), findsOneWidget);
    expect(find.text('Check-in'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
  });
}
