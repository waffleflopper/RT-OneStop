import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/models/calculator_models.dart';

/// Repository for loading and accessing calculator definitions
class CalculatorRepository {
  List<CalculatorDefinition>? _cachedCalculators;
  Map<String, List<CalculatorDefinition>>? _cachedByCategory;

  /// Load all calculator definitions from assets
  Future<List<CalculatorDefinition>> loadCalculators() async {
    if (_cachedCalculators != null) {
      return _cachedCalculators!;
    }

    final jsonString = await rootBundle.loadString('assets/data/calculators.json');
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final calculatorsList = jsonData['calculators'] as List<dynamic>;

    _cachedCalculators = calculatorsList
        .map((e) => CalculatorDefinition.fromJson(e as Map<String, dynamic>))
        .toList();

    return _cachedCalculators!;
  }

  /// Get calculator by ID
  Future<CalculatorDefinition?> getCalculator(String id) async {
    final calculators = await loadCalculators();
    return calculators.where((c) => c.id == id).firstOrNull;
  }

  /// Get calculators grouped by category
  Future<Map<String, List<CalculatorDefinition>>> getCalculatorsByCategory() async {
    if (_cachedByCategory != null) {
      return _cachedByCategory!;
    }

    final calculators = await loadCalculators();
    _cachedByCategory = {};

    for (final calculator in calculators) {
      _cachedByCategory!.putIfAbsent(calculator.category, () => []);
      _cachedByCategory![calculator.category]!.add(calculator);
    }

    return _cachedByCategory!;
  }

  /// Get all unique categories
  Future<List<String>> getCategories() async {
    final byCategory = await getCalculatorsByCategory();
    return byCategory.keys.toList()..sort();
  }

  /// Search calculators by name or description
  Future<List<CalculatorDefinition>> searchCalculators(String query) async {
    final calculators = await loadCalculators();
    final lowerQuery = query.toLowerCase();

    return calculators.where((c) {
      return c.name.toLowerCase().contains(lowerQuery) ||
          c.description.toLowerCase().contains(lowerQuery) ||
          c.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
