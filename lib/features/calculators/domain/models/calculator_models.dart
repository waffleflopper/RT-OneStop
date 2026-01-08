import 'package:equatable/equatable.dart';

/// Unit conversion option
class UnitOption extends Equatable {
  final String unit;
  final double conversionFactor;
  final double offset;

  const UnitOption({
    required this.unit,
    required this.conversionFactor,
    this.offset = 0,
  });

  factory UnitOption.fromJson(Map<String, dynamic> json) {
    return UnitOption(
      unit: json['unit'] as String,
      conversionFactor: (json['conversionFactor'] as num).toDouble(),
      offset: (json['offset'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'unit': unit,
        'conversionFactor': conversionFactor,
        'offset': offset,
      };

  @override
  List<Object?> get props => [unit, conversionFactor, offset];
}

/// Input field definition for a calculator
class InputField extends Equatable {
  final String id;
  final String label;
  final String defaultUnit;
  final List<UnitOption> alternateUnits;
  final double? minValue;
  final double? maxValue;
  final double? warningMin;
  final double? warningMax;
  final String? hint;
  final double? defaultValue;

  const InputField({
    required this.id,
    required this.label,
    required this.defaultUnit,
    this.alternateUnits = const [],
    this.minValue,
    this.maxValue,
    this.warningMin,
    this.warningMax,
    this.hint,
    this.defaultValue,
  });

  factory InputField.fromJson(Map<String, dynamic> json) {
    return InputField(
      id: json['id'] as String,
      label: json['label'] as String,
      defaultUnit: json['defaultUnit'] as String,
      alternateUnits: (json['alternateUnits'] as List<dynamic>?)
              ?.map((e) => UnitOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      minValue: (json['minValue'] as num?)?.toDouble(),
      maxValue: (json['maxValue'] as num?)?.toDouble(),
      warningMin: (json['warningMin'] as num?)?.toDouble(),
      warningMax: (json['warningMax'] as num?)?.toDouble(),
      hint: json['hint'] as String?,
      defaultValue: (json['defaultValue'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'defaultUnit': defaultUnit,
        'alternateUnits': alternateUnits.map((e) => e.toJson()).toList(),
        'minValue': minValue,
        'maxValue': maxValue,
        'warningMin': warningMin,
        'warningMax': warningMax,
        'hint': hint,
        'defaultValue': defaultValue,
      };

  /// Get all available units including default
  List<String> get allUnits {
    return [defaultUnit, ...alternateUnits.map((u) => u.unit)];
  }

  @override
  List<Object?> get props => [
        id,
        label,
        defaultUnit,
        alternateUnits,
        minValue,
        maxValue,
        warningMin,
        warningMax,
        hint,
        defaultValue,
      ];
}

/// Output field definition
class OutputField extends Equatable {
  final String id;
  final String label;
  final String unit;
  final int decimalPlaces;
  final String? interpretation;

  const OutputField({
    required this.id,
    required this.label,
    required this.unit,
    this.decimalPlaces = 2,
    this.interpretation,
  });

  factory OutputField.fromJson(Map<String, dynamic> json) {
    return OutputField(
      id: json['id'] as String,
      label: json['label'] as String,
      unit: json['unit'] as String,
      decimalPlaces: json['decimalPlaces'] as int? ?? 2,
      interpretation: json['interpretation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'unit': unit,
        'decimalPlaces': decimalPlaces,
        'interpretation': interpretation,
      };

  @override
  List<Object?> get props => [id, label, unit, decimalPlaces, interpretation];
}

/// Complete calculator definition
class CalculatorDefinition extends Equatable {
  final String id;
  final String name;
  final String category;
  final String description;
  final String formula;
  final List<InputField> inputs;
  final List<OutputField> outputs;
  final String clinicalNote;
  final List<String> sourceUrls;
  final String? alternateFormula;

  const CalculatorDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.formula,
    required this.inputs,
    required this.outputs,
    required this.clinicalNote,
    this.sourceUrls = const [],
    this.alternateFormula,
  });

  factory CalculatorDefinition.fromJson(Map<String, dynamic> json) {
    return CalculatorDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      formula: json['formula'] as String,
      inputs: (json['inputs'] as List<dynamic>)
          .map((e) => InputField.fromJson(e as Map<String, dynamic>))
          .toList(),
      outputs: (json['outputs'] as List<dynamic>)
          .map((e) => OutputField.fromJson(e as Map<String, dynamic>))
          .toList(),
      clinicalNote: json['clinicalNote'] as String,
      sourceUrls: (json['sourceUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      alternateFormula: json['alternateFormula'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
        'formula': formula,
        'inputs': inputs.map((e) => e.toJson()).toList(),
        'outputs': outputs.map((e) => e.toJson()).toList(),
        'clinicalNote': clinicalNote,
        'sourceUrls': sourceUrls,
        'alternateFormula': alternateFormula,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        description,
        formula,
        inputs,
        outputs,
        clinicalNote,
        sourceUrls,
        alternateFormula,
      ];
}

/// Calculator category for grouping
class CalculatorCategory extends Equatable {
  final String id;
  final String name;
  final String icon;
  final List<CalculatorDefinition> calculators;

  const CalculatorCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.calculators = const [],
  });

  @override
  List<Object?> get props => [id, name, icon, calculators];
}

/// Input validation result
class ValidationResult extends Equatable {
  final bool isValid;
  final String? errorMessage;
  final bool hasWarning;
  final String? warningMessage;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.hasWarning = false,
    this.warningMessage,
  });

  const ValidationResult.valid()
      : isValid = true,
        errorMessage = null,
        hasWarning = false,
        warningMessage = null;

  const ValidationResult.error(String message)
      : isValid = false,
        errorMessage = message,
        hasWarning = false,
        warningMessage = null;

  const ValidationResult.warning(String message)
      : isValid = true,
        errorMessage = null,
        hasWarning = true,
        warningMessage = message;

  @override
  List<Object?> get props => [isValid, errorMessage, hasWarning, warningMessage];
}

/// Calculation result
class CalculationResult extends Equatable {
  final Map<String, double> outputs;
  final Map<String, ValidationResult> inputValidations;
  final bool isSuccessful;
  final String? errorMessage;

  const CalculationResult({
    required this.outputs,
    required this.inputValidations,
    required this.isSuccessful,
    this.errorMessage,
  });

  const CalculationResult.success({
    required Map<String, double> outputs,
    Map<String, ValidationResult> inputValidations = const {},
  })  : outputs = outputs,
        inputValidations = inputValidations,
        isSuccessful = true,
        errorMessage = null;

  const CalculationResult.error(String message)
      : outputs = const {},
        inputValidations = const {},
        isSuccessful = false,
        errorMessage = message;

  @override
  List<Object?> get props => [outputs, inputValidations, isSuccessful, errorMessage];
}
