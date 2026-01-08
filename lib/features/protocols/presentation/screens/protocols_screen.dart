import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/protocol_models.dart';
import '../providers/protocol_providers.dart';

class ProtocolsScreen extends ConsumerWidget {
  const ProtocolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final protocolsAsync = ref.watch(protocolsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Protocols'),
      ),
      body: Column(
        children: [
          // Disclaimer banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These are reference guides only. Always follow your institution\'s protocols and physician orders.',
                    style: TextStyle(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Protocol list
          Expanded(
            child: protocolsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (protocols) {
                if (protocols.isEmpty) {
                  return const Center(child: Text('No protocols available'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: protocols.length,
                  itemBuilder: (context, index) {
                    final protocol = protocols[index];
                    return _ProtocolCard(protocol: protocol);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtocolCard extends StatelessWidget {
  final ProtocolDefinition protocol;

  const _ProtocolCard({required this.protocol});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/protocols/${protocol.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getTypeColor(protocol.type, theme).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(protocol.type),
                  color: _getTypeColor(protocol.type, theme),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      protocol.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      protocol.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(_getTypeLabel(protocol.type)),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${protocol.totalItems} items',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'emergency':
        return Icons.emergency;
      case 'procedure':
        return Icons.medical_services;
      case 'setup':
        return Icons.settings_suggest;
      default:
        return Icons.checklist;
    }
  }

  Color _getTypeColor(String type, ThemeData theme) {
    switch (type) {
      case 'emergency':
        return Colors.red;
      case 'procedure':
        return theme.colorScheme.primary;
      case 'setup':
        return Colors.orange;
      default:
        return theme.colorScheme.secondary;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'emergency':
        return 'Emergency';
      case 'procedure':
        return 'Procedure';
      case 'setup':
        return 'Setup';
      default:
        return type;
    }
  }
}
