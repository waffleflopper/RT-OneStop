import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/models/settings_models.dart';

/// Repository for managing user preferences and calculation history
class SettingsRepository {
  Box<String>? _preferencesBox;
  Box<String>? _historyBox;
  final _uuid = const Uuid();

  Future<Box<String>> get _preferences async {
    _preferencesBox ??=
        await Hive.openBox<String>(AppConstants.preferencesBox);
    return _preferencesBox!;
  }

  Future<Box<String>> get _history async {
    _historyBox ??= await Hive.openBox<String>(AppConstants.historyBox);
    return _historyBox!;
  }

  // ============ Preferences ============

  /// Load user preferences
  Future<UserPreferences> loadPreferences() async {
    final box = await _preferences;
    final data = box.get('user_preferences');
    if (data != null) {
      try {
        return UserPreferences.fromJson(
          json.decode(data) as Map<String, dynamic>,
        );
      } catch (_) {
        return const UserPreferences();
      }
    }
    return const UserPreferences();
  }

  /// Save user preferences
  Future<void> savePreferences(UserPreferences preferences) async {
    final box = await _preferences;
    await box.put('user_preferences', json.encode(preferences.toJson()));
  }

  /// Check if disclaimer has been acknowledged
  Future<bool> hasAcknowledgedDisclaimer() async {
    final prefs = await loadPreferences();
    return prefs.hasAcknowledgedDisclaimer;
  }

  /// Acknowledge disclaimer
  Future<void> acknowledgeDisclaimer() async {
    final prefs = await loadPreferences();
    await savePreferences(prefs.copyWith(hasAcknowledgedDisclaimer: true));
  }

  /// Update theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await loadPreferences();
    await savePreferences(prefs.copyWith(themeMode: mode));
  }

  /// Update unit system
  Future<void> setUnitSystem(UnitSystem system) async {
    final prefs = await loadPreferences();
    await savePreferences(prefs.copyWith(defaultUnitSystem: system));
  }

  /// Toggle calculator favorite
  Future<void> toggleCalculatorFavorite(String calculatorId) async {
    final prefs = await loadPreferences();
    final favorites = Set<String>.from(prefs.favoriteCalculators);
    if (favorites.contains(calculatorId)) {
      favorites.remove(calculatorId);
    } else {
      favorites.add(calculatorId);
    }
    await savePreferences(prefs.copyWith(favoriteCalculators: favorites));
  }

  /// Check if calculator is favorite
  Future<bool> isCalculatorFavorite(String calculatorId) async {
    final prefs = await loadPreferences();
    return prefs.favoriteCalculators.contains(calculatorId);
  }

  // ============ History ============

  /// Load all calculation history
  Future<List<CalculationHistory>> loadHistory() async {
    final box = await _history;
    final historyList = <CalculationHistory>[];

    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        try {
          historyList.add(CalculationHistory.fromJson(
            json.decode(data) as Map<String, dynamic>,
          ));
        } catch (_) {
          // Skip invalid entries
        }
      }
    }

    // Sort by timestamp, newest first
    historyList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return historyList;
  }

  /// Save a calculation to history
  Future<CalculationHistory> saveCalculation({
    required String calculatorId,
    required String calculatorName,
    required Map<String, dynamic> inputs,
    required Map<String, dynamic> outputs,
    String? notes,
  }) async {
    final box = await _history;
    final entry = CalculationHistory(
      id: _uuid.v4(),
      calculatorId: calculatorId,
      calculatorName: calculatorName,
      timestamp: DateTime.now(),
      inputs: inputs,
      outputs: outputs,
      notes: notes,
    );

    await box.put(entry.id, json.encode(entry.toJson()));
    return entry;
  }

  /// Delete a history entry
  Future<void> deleteHistoryEntry(String id) async {
    final box = await _history;
    await box.delete(id);
  }

  /// Clear all history
  Future<void> clearHistory() async {
    final box = await _history;
    await box.clear();
  }

  /// Update notes for a history entry
  Future<void> updateHistoryNotes(String id, String? notes) async {
    final box = await _history;
    final data = box.get(id);
    if (data != null) {
      final entry = CalculationHistory.fromJson(
        json.decode(data) as Map<String, dynamic>,
      );
      final updated = entry.copyWith(notes: notes);
      await box.put(id, json.encode(updated.toJson()));
    }
  }

  /// Get history entries for a specific calculator
  Future<List<CalculationHistory>> getHistoryForCalculator(
      String calculatorId) async {
    final history = await loadHistory();
    return history.where((h) => h.calculatorId == calculatorId).toList();
  }
}
