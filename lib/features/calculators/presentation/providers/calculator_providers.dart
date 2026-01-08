import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/calculator_repository.dart';
import '../../domain/models/calculator_models.dart';
import '../../domain/calculator_engine.dart';

/// Provider for calculator repository
final calculatorRepositoryProvider = Provider<CalculatorRepository>((ref) {
  return CalculatorRepository();
});

/// Provider for calculator engine
final calculatorEngineProvider = Provider<CalculatorEngine>((ref) {
  return CalculatorEngine();
});

/// Provider for all calculators
final calculatorsProvider = FutureProvider<List<CalculatorDefinition>>((ref) async {
  final repository = ref.watch(calculatorRepositoryProvider);
  return repository.loadCalculators();
});

/// Provider for calculators grouped by category
final calculatorsByCategoryProvider =
    FutureProvider<Map<String, List<CalculatorDefinition>>>((ref) async {
  final repository = ref.watch(calculatorRepositoryProvider);
  return repository.getCalculatorsByCategory();
});

/// Provider for a single calculator by ID
final calculatorProvider =
    FutureProvider.family<CalculatorDefinition?, String>((ref, id) async {
  final repository = ref.watch(calculatorRepositoryProvider);
  return repository.getCalculator(id);
});

/// Provider for calculator search
final calculatorSearchProvider =
    FutureProvider.family<List<CalculatorDefinition>, String>((ref, query) async {
  if (query.isEmpty) {
    return ref.watch(calculatorsProvider).value ?? [];
  }
  final repository = ref.watch(calculatorRepositoryProvider);
  return repository.searchCalculators(query);
});

/// State notifier for calculator input values
class CalculatorInputNotifier extends StateNotifier<Map<String, double>> {
  CalculatorInputNotifier() : super({});

  void setValue(String fieldId, double value) {
    state = {...state, fieldId: value};
  }

  void clear() {
    state = {};
  }

  void setAll(Map<String, double> values) {
    state = values;
  }
}

/// Provider for calculator input values
final calculatorInputProvider =
    StateNotifierProvider.family<CalculatorInputNotifier, Map<String, double>, String>(
        (ref, calculatorId) {
  return CalculatorInputNotifier();
});

/// State notifier for selected units
class CalculatorUnitNotifier extends StateNotifier<Map<String, String>> {
  CalculatorUnitNotifier() : super({});

  void setUnit(String fieldId, String unit) {
    state = {...state, fieldId: unit};
  }

  void clear() {
    state = {};
  }
}

/// Provider for selected units
final calculatorUnitProvider =
    StateNotifierProvider.family<CalculatorUnitNotifier, Map<String, String>, String>(
        (ref, calculatorId) {
  return CalculatorUnitNotifier();
});

/// Provider for calculation result
final calculationResultProvider =
    Provider.family<CalculationResult?, String>((ref, calculatorId) {
  final calculatorAsync = ref.watch(calculatorProvider(calculatorId));
  final inputs = ref.watch(calculatorInputProvider(calculatorId));
  final units = ref.watch(calculatorUnitProvider(calculatorId));
  final engine = ref.watch(calculatorEngineProvider);

  return calculatorAsync.whenOrNull(
    data: (calculator) {
      if (calculator == null) return null;

      // Check if all required inputs have values
      for (final field in calculator.inputs) {
        if (!inputs.containsKey(field.id)) {
          return null;
        }
      }

      return engine.calculate(calculator, inputs, units);
    },
  );
});
