import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

/// User preferences
class UserPreferences extends Equatable {
  final bool hasAcknowledgedDisclaimer;
  final UnitSystem defaultUnitSystem;
  final AppThemeMode themeMode;
  final Set<String> favoriteCalculators;
  final Set<String> favoriteReferences;

  const UserPreferences({
    this.hasAcknowledgedDisclaimer = false,
    this.defaultUnitSystem = UnitSystem.metric,
    this.themeMode = AppThemeMode.system,
    this.favoriteCalculators = const {},
    this.favoriteReferences = const {},
  });

  UserPreferences copyWith({
    bool? hasAcknowledgedDisclaimer,
    UnitSystem? defaultUnitSystem,
    AppThemeMode? themeMode,
    Set<String>? favoriteCalculators,
    Set<String>? favoriteReferences,
  }) {
    return UserPreferences(
      hasAcknowledgedDisclaimer:
          hasAcknowledgedDisclaimer ?? this.hasAcknowledgedDisclaimer,
      defaultUnitSystem: defaultUnitSystem ?? this.defaultUnitSystem,
      themeMode: themeMode ?? this.themeMode,
      favoriteCalculators: favoriteCalculators ?? this.favoriteCalculators,
      favoriteReferences: favoriteReferences ?? this.favoriteReferences,
    );
  }

  Map<String, dynamic> toJson() => {
        'hasAcknowledgedDisclaimer': hasAcknowledgedDisclaimer,
        'defaultUnitSystem': defaultUnitSystem.name,
        'themeMode': themeMode.name,
        'favoriteCalculators': favoriteCalculators.toList(),
        'favoriteReferences': favoriteReferences.toList(),
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      hasAcknowledgedDisclaimer:
          json['hasAcknowledgedDisclaimer'] as bool? ?? false,
      defaultUnitSystem: UnitSystem.values.firstWhere(
        (e) => e.name == json['defaultUnitSystem'],
        orElse: () => UnitSystem.metric,
      ),
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => AppThemeMode.system,
      ),
      favoriteCalculators: (json['favoriteCalculators'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      favoriteReferences: (json['favoriteReferences'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
    );
  }

  @override
  List<Object?> get props => [
        hasAcknowledgedDisclaimer,
        defaultUnitSystem,
        themeMode,
        favoriteCalculators,
        favoriteReferences,
      ];
}

/// A saved calculation history entry
class CalculationHistory extends Equatable {
  final String id;
  final String calculatorId;
  final String calculatorName;
  final DateTime timestamp;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> outputs;
  final String? notes;

  const CalculationHistory({
    required this.id,
    required this.calculatorId,
    required this.calculatorName,
    required this.timestamp,
    required this.inputs,
    required this.outputs,
    this.notes,
  });

  CalculationHistory copyWith({
    String? id,
    String? calculatorId,
    String? calculatorName,
    DateTime? timestamp,
    Map<String, dynamic>? inputs,
    Map<String, dynamic>? outputs,
    String? notes,
  }) {
    return CalculationHistory(
      id: id ?? this.id,
      calculatorId: calculatorId ?? this.calculatorId,
      calculatorName: calculatorName ?? this.calculatorName,
      timestamp: timestamp ?? this.timestamp,
      inputs: inputs ?? this.inputs,
      outputs: outputs ?? this.outputs,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'calculatorId': calculatorId,
        'calculatorName': calculatorName,
        'timestamp': timestamp.toIso8601String(),
        'inputs': inputs,
        'outputs': outputs,
        'notes': notes,
      };

  factory CalculationHistory.fromJson(Map<String, dynamic> json) {
    return CalculationHistory(
      id: json['id'] as String,
      calculatorId: json['calculatorId'] as String,
      calculatorName: json['calculatorName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      inputs: Map<String, dynamic>.from(json['inputs'] as Map),
      outputs: Map<String, dynamic>.from(json['outputs'] as Map),
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [id, calculatorId, calculatorName, timestamp, inputs, outputs, notes];
}
