import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/models/reference_models.dart';

/// Repository for loading and accessing reference data
class ReferenceRepository {
  List<ReferenceCategory>? _cachedCategories;

  /// Load all reference categories from assets
  Future<List<ReferenceCategory>> loadCategories() async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }

    final jsonString =
        await rootBundle.loadString('assets/data/reference_ranges.json');
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final categoriesList = jsonData['categories'] as List<dynamic>;

    _cachedCategories = categoriesList
        .map((e) => ReferenceCategory.fromJson(e as Map<String, dynamic>))
        .toList();

    return _cachedCategories!;
  }

  /// Get categories filtered by population
  Future<List<ReferenceCategory>> getCategoriesByPopulation(
      Population population) async {
    final categories = await loadCategories();
    return categories
        .where((c) => c.population == population.value)
        .toList();
  }

  /// Get category by ID
  Future<ReferenceCategory?> getCategory(String id) async {
    final categories = await loadCategories();
    return categories.where((c) => c.id == id).firstOrNull;
  }

  /// Search reference items across all categories
  Future<List<MapEntry<ReferenceCategory, List<ReferenceItem>>>> searchReferences(
      String query, Population? population) async {
    final categories = await loadCategories();
    final lowerQuery = query.toLowerCase();
    final results = <MapEntry<ReferenceCategory, List<ReferenceItem>>>[];

    for (final category in categories) {
      if (population != null && category.population != population.value) {
        continue;
      }

      final matchingItems = category.items.where((item) {
        return item.parameter.toLowerCase().contains(lowerQuery) ||
            (item.notes?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();

      if (matchingItems.isNotEmpty) {
        results.add(MapEntry(category, matchingItems));
      }
    }

    return results;
  }

  /// Get all unique category names
  Future<List<String>> getCategoryNames() async {
    final categories = await loadCategories();
    return categories.map((c) => c.name).toSet().toList()..sort();
  }
}
