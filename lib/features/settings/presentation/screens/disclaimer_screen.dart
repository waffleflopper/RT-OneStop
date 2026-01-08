import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/settings_providers.dart';

class DisclaimerScreen extends ConsumerWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // App logo/icon
              Icon(
                Icons.medical_services,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),

              // App name
              Text(
                AppConstants.appName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Disclaimer title
              Text(
                AppConstants.disclaimerTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Disclaimer card
              Expanded(
                flex: 2,
                child: Card(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Please read carefully before continuing',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppConstants.disclaimerText,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'Key Points:',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _BulletPoint(
                          text: 'This app is for educational and reference purposes only',
                          theme: theme,
                        ),
                        _BulletPoint(
                          text: 'It does not provide medical advice',
                          theme: theme,
                        ),
                        _BulletPoint(
                          text: 'Always follow institutional protocols and physician orders',
                          theme: theme,
                        ),
                        _BulletPoint(
                          text: 'Verify all calculations independently before clinical use',
                          theme: theme,
                        ),
                        _BulletPoint(
                          text: 'No patient health information (PHI) is stored',
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Acknowledge button
              FilledButton.icon(
                onPressed: () {
                  ref.read(preferencesProvider.notifier).acknowledgeDisclaimer();
                },
                icon: const Icon(Icons.check),
                label: const Text('I Understand and Accept'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 16),

              // Footer text
              Text(
                'By tapping "I Understand and Accept", you acknowledge that you have read and understood this disclaimer.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final ThemeData theme;

  const _BulletPoint({required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: theme.textTheme.bodyMedium),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
