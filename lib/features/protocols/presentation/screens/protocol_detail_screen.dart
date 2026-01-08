import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/protocol_models.dart';
import '../providers/protocol_providers.dart';

class ProtocolDetailScreen extends ConsumerWidget {
  final String protocolId;

  const ProtocolDetailScreen({super.key, required this.protocolId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final protocolAsync = ref.watch(protocolProvider(protocolId));
    final checklistState = ref.watch(checklistStateProvider(protocolId));
    final progress = ref.watch(checklistProgressProvider(protocolId));

    return protocolAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (protocol) {
        if (protocol == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Protocol not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(protocol.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.read(checklistStateProvider(protocolId).notifier).reset();
                },
                tooltip: 'Reset checklist',
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress bar
              _ProgressBar(progress: progress, checklistState: checklistState),

              // Disclaimer
              _DisclaimerBanner(disclaimer: protocol.disclaimer),

              // Checklist
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: protocol.sections.length,
                  itemBuilder: (context, index) {
                    final section = protocol.sections[index];
                    return _SectionCard(
                      section: section,
                      checklistState: checklistState,
                      onItemToggle: (itemId) {
                        ref
                            .read(checklistStateProvider(protocolId).notifier)
                            .toggleItem(itemId);
                      },
                      onNoteChanged: (itemId, note) {
                        ref
                            .read(checklistStateProvider(protocolId).notifier)
                            .setNote(itemId, note);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final ChecklistState checklistState;

  const _ProgressBar({
    required this.progress,
    required this.checklistState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: theme.textTheme.titleSmall,
              ),
              Text(
                '$percentage% (${checklistState.completedCount} completed)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  final String disclaimer;

  const _DisclaimerBanner({required this.disclaimer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              disclaimer,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final ChecklistSection section;
  final ChecklistState checklistState;
  final void Function(String) onItemToggle;
  final void Function(String, String) onNoteChanged;

  const _SectionCard({
    required this.section,
    required this.checklistState,
    required this.onItemToggle,
    required this.onNoteChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Text(
              section.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),

          // Items
          ...section.items.map((item) => _ChecklistItemTile(
                item: item,
                isCompleted: checklistState.isItemCompleted(item.id),
                note: checklistState.getNote(item.id),
                onToggle: () => onItemToggle(item.id),
                onNoteChanged: (note) => onNoteChanged(item.id, note),
              )),
        ],
      ),
    );
  }
}

class _ChecklistItemTile extends StatefulWidget {
  final ChecklistItem item;
  final bool isCompleted;
  final String? note;
  final VoidCallback onToggle;
  final void Function(String) onNoteChanged;

  const _ChecklistItemTile({
    required this.item,
    required this.isCompleted,
    this.note,
    required this.onToggle,
    required this.onNoteChanged,
  });

  @override
  State<_ChecklistItemTile> createState() => _ChecklistItemTileState();
}

class _ChecklistItemTileState extends State<_ChecklistItemTile> {
  bool _showNoteField = false;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.note);
    _showNoteField = widget.note != null && widget.note!.isNotEmpty;
  }

  @override
  void didUpdateWidget(_ChecklistItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note != widget.note) {
      _noteController.text = widget.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: Checkbox(
            value: widget.isCompleted,
            onChanged: (_) => widget.onToggle(),
          ),
          title: Text(
            widget.item.text,
            style: TextStyle(
              decoration: widget.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: widget.isCompleted
                  ? theme.colorScheme.outline
                  : null,
            ),
          ),
          subtitle: widget.item.subtext != null
              ? Text(
                  widget.item.subtext!,
                  style: theme.textTheme.bodySmall,
                )
              : null,
          trailing: IconButton(
            icon: Icon(
              _showNoteField ? Icons.note : Icons.note_add_outlined,
              size: 20,
            ),
            onPressed: () {
              setState(() => _showNoteField = !_showNoteField);
            },
            tooltip: 'Add note',
          ),
          onTap: widget.onToggle,
        ),
        if (_showNoteField)
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
            child: TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Add a note...',
                isDense: true,
              ),
              maxLines: 2,
              onChanged: widget.onNoteChanged,
            ),
          ),
        const Divider(height: 1, indent: 56),
      ],
    );
  }
}
