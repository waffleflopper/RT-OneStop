import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

/// Main app shell with bottom navigation
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentTab = getCurrentTab(location);
    final selectedIndex = currentTab?.index ?? 0;

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        final tab = NavigationTab.values[index];
        context.go(tab.path);
      },
      destinations: NavigationTab.values.map((tab) {
        return NavigationDestination(
          icon: Icon(tab.icon),
          selectedIcon: Icon(tab.selectedIcon),
          label: tab.label,
        );
      }).toList(),
    );
  }
}
