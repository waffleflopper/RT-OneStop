import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/settings_repository.dart';
import '../../domain/models/settings_models.dart';

/// Provider for settings repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// State notifier for user preferences
class PreferencesNotifier extends StateNotifier<UserPreferences> {
  final SettingsRepository _repository;

  PreferencesNotifier(this._repository) : super(const UserPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await _repository.loadPreferences();
    state = prefs;
  }

  Future<void> acknowledgeDisclaimer() async {
    await _repository.acknowledgeDisclaimer();
    state = state.copyWith(hasAcknowledgedDisclaimer: true);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _repository.setThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setUnitSystem(UnitSystem system) async {
    await _repository.setUnitSystem(system);
    state = state.copyWith(defaultUnitSystem: system);
  }

  Future<void> toggleCalculatorFavorite(String calculatorId) async {
    await _repository.toggleCalculatorFavorite(calculatorId);
    final favorites = Set<String>.from(state.favoriteCalculators);
    if (favorites.contains(calculatorId)) {
      favorites.remove(calculatorId);
    } else {
      favorites.add(calculatorId);
    }
    state = state.copyWith(favoriteCalculators: favorites);
  }

  bool isCalculatorFavorite(String calculatorId) {
    return state.favoriteCalculators.contains(calculatorId);
  }

  Future<void> reload() async {
    await _loadPreferences();
  }
}

/// Provider for preferences state
final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, UserPreferences>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return PreferencesNotifier(repository);
});

/// Provider for theme mode
final themeModeProvider = Provider<ThemeMode>((ref) {
  final prefs = ref.watch(preferencesProvider);
  switch (prefs.themeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});

/// Provider for disclaimer acknowledged status
final disclaimerAcknowledgedProvider = Provider<bool>((ref) {
  final prefs = ref.watch(preferencesProvider);
  return prefs.hasAcknowledgedDisclaimer;
});

/// State notifier for calculation history
class HistoryNotifier extends StateNotifier<List<CalculationHistory>> {
  final SettingsRepository _repository;

  HistoryNotifier(this._repository) : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _repository.loadHistory();
    state = history;
  }

  Future<CalculationHistory> saveCalculation({
    required String calculatorId,
    required String calculatorName,
    required Map<String, dynamic> inputs,
    required Map<String, dynamic> outputs,
    String? notes,
  }) async {
    final entry = await _repository.saveCalculation(
      calculatorId: calculatorId,
      calculatorName: calculatorName,
      inputs: inputs,
      outputs: outputs,
      notes: notes,
    );
    state = [entry, ...state];
    return entry;
  }

  Future<void> deleteEntry(String id) async {
    await _repository.deleteHistoryEntry(id);
    state = state.where((h) => h.id != id).toList();
  }

  Future<void> clearHistory() async {
    await _repository.clearHistory();
    state = [];
  }

  Future<void> updateNotes(String id, String? notes) async {
    await _repository.updateHistoryNotes(id, notes);
    state = state.map((h) {
      if (h.id == id) {
        return h.copyWith(notes: notes);
      }
      return h;
    }).toList();
  }

  Future<void> reload() async {
    await _loadHistory();
  }
}

/// Provider for history state
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<CalculationHistory>>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return HistoryNotifier(repository);
});

/// Provider for recent calculations (limited to 5)
final recentCalculationsProvider = Provider<List<CalculationHistory>>((ref) {
  final history = ref.watch(historyProvider);
  return history.take(5).toList();
});

/// Provider for history count
final historyCountProvider = Provider<int>((ref) {
  final history = ref.watch(historyProvider);
  return history.length;
});
