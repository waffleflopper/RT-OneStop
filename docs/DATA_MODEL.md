# Data Model - RT OneStop

## Calculator Schema

Calculators are defined as structured data to enable adding new formulas without UI changes.

### Calculator Definition

```dart
class CalculatorDefinition {
  final String id;              // Unique identifier (e.g., "minute_ventilation")
  final String name;            // Display name (e.g., "Minute Ventilation")
  final String category;        // Category (e.g., "Ventilation")
  final String description;     // Plain-language description
  final String formula;         // Formula display (e.g., "VE = VT × RR")
  final List<InputField> inputs;
  final List<OutputField> outputs;
  final String clinicalNote;    // Clinical caveats
  final List<String> sourceUrls;
  final String? alternateFormula; // Optional alternate calculation method
}
```

### Input Field Definition

```dart
class InputField {
  final String id;              // Unique within calculator
  final String label;           // Display label
  final String defaultUnit;     // Primary unit
  final List<UnitOption>? alternateUnits; // For unit conversion
  final double? minValue;       // Validation minimum
  final double? maxValue;       // Validation maximum
  final double? warningMin;     // Warning threshold (implausible low)
  final double? warningMax;     // Warning threshold (implausible high)
  final String? hint;           // Helper text
  final double? defaultValue;   // Optional default
}
```

### Unit Conversion

```dart
class UnitOption {
  final String unit;            // Unit name (e.g., "kPa")
  final double conversionFactor; // Multiply by this to convert to default unit
  final double? offset;         // Add after multiplication (for temp conversions)
}
```

### Output Field Definition

```dart
class OutputField {
  final String id;
  final String label;
  final String unit;
  final int decimalPlaces;
  final String? interpretation; // Optional interpretation guide
}
```

---

## Reference Range Schema

### Reference Category

```dart
class ReferenceCategory {
  final String id;
  final String name;
  final String population;      // "neonatal", "pediatric", "adult"
  final List<ReferenceItem> items;
  final String? lastReviewed;   // ISO date string
  final List<String> sourceUrls;
}
```

### Reference Item

```dart
class ReferenceItem {
  final String id;
  final String parameter;       // e.g., "Heart Rate"
  final String? ageRange;       // e.g., "0-3 months" (null if not age-specific)
  final String normalRange;     // e.g., "100-160 bpm"
  final String unit;
  final String? notes;          // Additional context
}
```

---

## Protocol/Checklist Schema

### Protocol Definition

```dart
class ProtocolDefinition {
  final String id;
  final String name;
  final String type;            // "procedure", "emergency", "setup"
  final String description;
  final String disclaimer;      // Protocol-specific disclaimer
  final List<ChecklistSection> sections;
  final List<String> sourceUrls;
}
```

### Checklist Section

```dart
class ChecklistSection {
  final String id;
  final String title;
  final List<ChecklistItem> items;
}
```

### Checklist Item

```dart
class ChecklistItem {
  final String id;
  final String text;
  final bool isOptional;
  final String? subtext;        // Additional detail
}
```

---

## Feed/News Schema

### Feed Item

```dart
class FeedItem {
  final String id;
  final String title;
  final String source;          // "aarc", "nbrc", "podcast"
  final DateTime publishedDate;
  final String? snippet;
  final String url;
  final String? imageUrl;
  final bool isRead;
}
```

### Feed Cache

```dart
class FeedCache {
  final String source;
  final DateTime lastFetched;
  final List<FeedItem> items;
}
```

---

## User Data Schema

### Calculation History Entry

```dart
class CalculationHistory {
  final String id;              // UUID
  final String calculatorId;
  final DateTime timestamp;
  final Map<String, dynamic> inputs;  // Input values with units
  final Map<String, dynamic> outputs; // Calculated results
  final String? notes;          // Optional user notes
}
```

### User Preferences

```dart
class UserPreferences {
  final bool hasAcknowledgedDisclaimer;
  final String defaultUnitSystem; // "metric" or "imperial"
  final String themeMode;         // "light", "dark", "system"
  final List<String> favoriteCalculators;
  final List<String> favoriteReferences;
}
```

---

## JSON Data File Structure

### calculators.json
```json
{
  "version": "1.0.0",
  "calculators": [
    {
      "id": "minute_ventilation",
      "name": "Minute Ventilation",
      "category": "Ventilation",
      ...
    }
  ]
}
```

### reference_ranges.json
```json
{
  "version": "1.0.0",
  "categories": [
    {
      "id": "vital_signs_neonatal",
      "name": "Vital Signs",
      "population": "neonatal",
      ...
    }
  ]
}
```

### protocols.json
```json
{
  "version": "1.0.0",
  "protocols": [
    {
      "id": "hfnc_neonate",
      "name": "HFNC Initiation - Neonate",
      ...
    }
  ]
}
```
