import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/protocol_repository.dart';
import '../../domain/models/protocol_models.dart';

/// Provider for protocol repository
final protocolRepositoryProvider = Provider<ProtocolRepository>((ref) {
  return ProtocolRepository();
});

/// Provider for all protocols
final protocolsProvider = FutureProvider<List<ProtocolDefinition>>((ref) async {
  final repository = ref.watch(protocolRepositoryProvider);
  return repository.loadProtocols();
});

/// Provider for a single protocol by ID
final protocolProvider =
    FutureProvider.family<ProtocolDefinition?, String>((ref, id) async {
  final repository = ref.watch(protocolRepositoryProvider);
  return repository.getProtocol(id);
});

/// State notifier for checklist state
class ChecklistStateNotifier extends StateNotifier<ChecklistState> {
  ChecklistStateNotifier(String protocolId)
      : super(ChecklistState(
          protocolId: protocolId,
          startedAt: DateTime.now(),
        ));

  void toggleItem(String itemId) {
    final newCompleted = Set<String>.from(state.completedItemIds);
    if (newCompleted.contains(itemId)) {
      newCompleted.remove(itemId);
    } else {
      newCompleted.add(itemId);
    }
    state = state.copyWith(completedItemIds: newCompleted);
  }

  void setNote(String itemId, String note) {
    final newNotes = Map<String, String>.from(state.itemNotes);
    if (note.isEmpty) {
      newNotes.remove(itemId);
    } else {
      newNotes[itemId] = note;
    }
    state = state.copyWith(itemNotes: newNotes);
  }

  void reset() {
    state = ChecklistState(
      protocolId: state.protocolId,
      startedAt: DateTime.now(),
    );
  }

  void completeAll(List<String> itemIds) {
    state = state.copyWith(completedItemIds: itemIds.toSet());
  }
}

/// Provider family for checklist state by protocol ID
final checklistStateProvider = StateNotifierProvider.family<
    ChecklistStateNotifier, ChecklistState, String>((ref, protocolId) {
  return ChecklistStateNotifier(protocolId);
});

/// Provider for calculating progress percentage
final checklistProgressProvider =
    Provider.family<double, String>((ref, protocolId) {
  final protocolAsync = ref.watch(protocolProvider(protocolId));
  final checklistState = ref.watch(checklistStateProvider(protocolId));

  return protocolAsync.whenOrNull(
        data: (protocol) {
          if (protocol == null) return 0.0;
          final totalItems = protocol.totalItems;
          if (totalItems == 0) return 0.0;
          return checklistState.completedCount / totalItems;
        },
      ) ??
      0.0;
});
