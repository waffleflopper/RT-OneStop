import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/settings_providers.dart';
import '../../../feed/data/feed_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    final historyCount = ref.watch(historyCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme section
          _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Theme'),
            subtitle: Text(_getThemeName(preferences.themeMode)),
            onTap: () => _showThemeDialog(context, ref, preferences.themeMode),
          ),

          const Divider(),

          // Units section
          _SectionHeader(title: 'Preferences'),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Default Unit System'),
            subtitle: Text(preferences.defaultUnitSystem == UnitSystem.metric
                ? 'Metric'
                : 'Imperial'),
            onTap: () => _showUnitDialog(context, ref, preferences.defaultUnitSystem),
          ),

          const Divider(),

          // Data section
          _SectionHeader(title: 'Data'),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Calculation History'),
            subtitle: Text('$historyCount saved calculations'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/history'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear History'),
            onTap: () => _confirmClearHistory(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Feeds'),
            subtitle: const Text('Fetch latest news and podcasts'),
            onTap: () => _refreshFeeds(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.cached),
            title: const Text('Clear Feed Cache'),
            onTap: () => _confirmClearFeedCache(context, ref),
          ),

          const Divider(),

          // About section
          _SectionHeader(title: 'About'),
          ListTile(
            leading: const Icon(Icons.gavel),
            title: const Text('Disclaimer'),
            onTap: () => _showDisclaimerDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Report an Issue'),
            onTap: () => _reportIssue(),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: Text('${AppConstants.appName} v${AppConstants.appVersion}'),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  String _getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System default';
    }
  }

  void _showThemeDialog(
      BuildContext context, WidgetRef ref, AppThemeMode current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(_getThemeName(mode)),
              value: mode,
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  ref.read(preferencesProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showUnitDialog(
      BuildContext context, WidgetRef ref, UnitSystem current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Unit System'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<UnitSystem>(
              title: const Text('Metric'),
              subtitle: const Text('cm, kg, mmHg'),
              value: UnitSystem.metric,
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  ref.read(preferencesProvider.notifier).setUnitSystem(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<UnitSystem>(
              title: const Text('Imperial'),
              subtitle: const Text('in, lb'),
              value: UnitSystem.imperial,
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  ref.read(preferencesProvider.notifier).setUnitSystem(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
            'Are you sure you want to delete all saved calculations? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _refreshFeeds(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing feeds...')),
    );

    try {
      final repository = ref.read(feedRepositoryProvider);
      await repository.fetchAllFeeds(forceRefresh: true);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feeds refreshed')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing feeds: $e')),
        );
      }
    }
  }

  void _confirmClearFeedCache(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Feed Cache'),
        content: const Text(
            'This will clear all cached news and podcast data. You will need an internet connection to reload.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final repository = ref.read(feedRepositoryProvider);
              await repository.clearCache();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feed cache cleared')),
                );
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDisclaimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConstants.disclaimerTitle),
        content: const SingleChildScrollView(
          child: Text(AppConstants.disclaimerText),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _reportIssue() async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppConstants.reportIssueEmail,
      query: 'subject=RT OneStop Issue Report',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: AppConstants.appName,
        applicationVersion: AppConstants.appVersion,
        applicationLegalese:
            'For educational and reference purposes only. Not medical advice.',
        children: const [
          SizedBox(height: 16),
          Text(
            'A cross-platform mobile app for Respiratory Therapists providing calculators, reference values, protocols, and news.',
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});
