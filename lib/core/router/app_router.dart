import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/settings/presentation/providers/settings_providers.dart';
import '../../shared/widgets/app_shell.dart';
import '../../features/calculators/presentation/screens/calculators_screen.dart';
import '../../features/calculators/presentation/screens/calculator_detail_screen.dart';
import '../../features/reference/presentation/screens/reference_screen.dart';
import '../../features/protocols/presentation/screens/protocols_screen.dart';
import '../../features/protocols/presentation/screens/protocol_detail_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/history_screen.dart';
import '../../features/settings/presentation/screens/disclaimer_screen.dart';

/// Router configuration provider
final routerProvider = Provider<GoRouter>((ref) {
  final disclaimerAcknowledged = ref.watch(disclaimerAcknowledgedProvider);

  return GoRouter(
    initialLocation: '/calculators',
    redirect: (context, state) {
      // Redirect to disclaimer if not acknowledged
      if (!disclaimerAcknowledged && state.uri.path != '/disclaimer') {
        return '/disclaimer';
      }
      // Redirect away from disclaimer if already acknowledged
      if (disclaimerAcknowledged && state.uri.path == '/disclaimer') {
        return '/calculators';
      }
      return null;
    },
    routes: [
      // Disclaimer route (outside shell)
      GoRoute(
        path: '/disclaimer',
        builder: (context, state) => const DisclaimerScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          // Calculators tab
          GoRoute(
            path: '/calculators',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalculatorsScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return CalculatorDetailScreen(calculatorId: id);
                },
              ),
            ],
          ),

          // Reference tab
          GoRoute(
            path: '/reference',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReferenceScreen(),
            ),
          ),

          // Protocols tab
          GoRoute(
            path: '/protocols',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProtocolsScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProtocolDetailScreen(protocolId: id);
                },
              ),
            ],
          ),

          // Feed tab
          GoRoute(
            path: '/feed',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FeedScreen(),
            ),
          ),

          // Settings tab
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Navigation destinations for bottom navigation
enum NavigationTab {
  calculators,
  reference,
  protocols,
  feed,
  settings,
}

extension NavigationTabExtension on NavigationTab {
  String get path {
    switch (this) {
      case NavigationTab.calculators:
        return '/calculators';
      case NavigationTab.reference:
        return '/reference';
      case NavigationTab.protocols:
        return '/protocols';
      case NavigationTab.feed:
        return '/feed';
      case NavigationTab.settings:
        return '/settings';
    }
  }

  String get label {
    switch (this) {
      case NavigationTab.calculators:
        return 'Calculators';
      case NavigationTab.reference:
        return 'Reference';
      case NavigationTab.protocols:
        return 'Protocols';
      case NavigationTab.feed:
        return 'Feed';
      case NavigationTab.settings:
        return 'Settings';
    }
  }

  IconData get icon {
    switch (this) {
      case NavigationTab.calculators:
        return Icons.calculate_outlined;
      case NavigationTab.reference:
        return Icons.menu_book_outlined;
      case NavigationTab.protocols:
        return Icons.checklist_outlined;
      case NavigationTab.feed:
        return Icons.newspaper_outlined;
      case NavigationTab.settings:
        return Icons.settings_outlined;
    }
  }

  IconData get selectedIcon {
    switch (this) {
      case NavigationTab.calculators:
        return Icons.calculate;
      case NavigationTab.reference:
        return Icons.menu_book;
      case NavigationTab.protocols:
        return Icons.checklist;
      case NavigationTab.feed:
        return Icons.newspaper;
      case NavigationTab.settings:
        return Icons.settings;
    }
  }
}

/// Helper to get current tab from location
NavigationTab? getCurrentTab(String location) {
  if (location.startsWith('/calculators')) return NavigationTab.calculators;
  if (location.startsWith('/reference')) return NavigationTab.reference;
  if (location.startsWith('/protocols')) return NavigationTab.protocols;
  if (location.startsWith('/feed')) return NavigationTab.feed;
  if (location.startsWith('/settings')) return NavigationTab.settings;
  return null;
}
