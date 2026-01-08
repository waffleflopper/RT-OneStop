import 'package:equatable/equatable.dart';

/// A single reference value item
class ReferenceItem extends Equatable {
  final String id;
  final String parameter;
  final String? ageRange;
  final String normalRange;
  final String unit;
  final String? notes;

  const ReferenceItem({
    required this.id,
    required this.parameter,
    this.ageRange,
    required this.normalRange,
    required this.unit,
    this.notes,
  });

  factory ReferenceItem.fromJson(Map<String, dynamic> json) {
    return ReferenceItem(
      id: json['id'] as String,
      parameter: json['parameter'] as String,
      ageRange: json['ageRange'] as String?,
      normalRange: json['normalRange'] as String,
      unit: json['unit'] as String,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'parameter': parameter,
        'ageRange': ageRange,
        'normalRange': normalRange,
        'unit': unit,
        'notes': notes,
      };

  @override
  List<Object?> get props => [id, parameter, ageRange, normalRange, unit, notes];
}

/// A category of reference values
class ReferenceCategory extends Equatable {
  final String id;
  final String name;
  final String population;
  final String? lastReviewed;
  final List<String> sourceUrls;
  final List<ReferenceItem> items;

  const ReferenceCategory({
    required this.id,
    required this.name,
    required this.population,
    this.lastReviewed,
    this.sourceUrls = const [],
    required this.items,
  });

  factory ReferenceCategory.fromJson(Map<String, dynamic> json) {
    return ReferenceCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      population: json['population'] as String,
      lastReviewed: json['lastReviewed'] as String?,
      sourceUrls: (json['sourceUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      items: (json['items'] as List<dynamic>)
          .map((e) => ReferenceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'population': population,
        'lastReviewed': lastReviewed,
        'sourceUrls': sourceUrls,
        'items': items.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, name, population, lastReviewed, sourceUrls, items];
}

/// Population types for filtering
enum Population {
  neonatal,
  pediatric,
  adult,
}

extension PopulationExtension on Population {
  String get displayName {
    switch (this) {
      case Population.neonatal:
        return 'Neonatal';
      case Population.pediatric:
        return 'Pediatric';
      case Population.adult:
        return 'Adult';
    }
  }

  String get value {
    switch (this) {
      case Population.neonatal:
        return 'neonatal';
      case Population.pediatric:
        return 'pediatric';
      case Population.adult:
        return 'adult';
    }
  }
}
