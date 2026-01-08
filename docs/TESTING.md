# Testing Strategy - RT OneStop

## Overview

Testing focuses on critical calculations and data parsing where correctness is essential for a medical reference application.

## Test Categories

### 1. Calculator Unit Tests

**Purpose**: Verify all calculator formulas produce correct results.

**Approach**: Golden input/output testing - provide known inputs and verify expected outputs.

```dart
test('Minute Ventilation calculation', () {
  final result = calculateMinuteVentilation(
    tidalVolume: 500, // mL
    respiratoryRate: 12, // breaths/min
  );
  expect(result, equals(6.0)); // L/min
});
```

**Coverage Requirements**:
- All 25+ calculators must have tests
- Test normal ranges
- Test edge cases (minimum/maximum valid inputs)
- Test unit conversions

### 2. Parser Tests

**Purpose**: Verify RSS and HTML feed parsing extracts correct data.

**Approach**: Use saved HTML/RSS samples as test fixtures.

```dart
test('AARC news parser extracts articles', () {
  final html = File('test/fixtures/aarc_news.html').readAsStringSync();
  final articles = parseAarcNews(html);

  expect(articles, isNotEmpty);
  expect(articles.first.title, isNotEmpty);
  expect(articles.first.url, startsWith('https://'));
});
```

**Coverage**:
- AARC news HTML parsing
- NBRC news HTML parsing
- AARC podcast RSS parsing
- Malformed input handling

### 3. Validation Tests

**Purpose**: Verify input validation catches implausible values.

```dart
test('Heart rate warning for implausible values', () {
  final validation = validateInput(
    value: 300,
    field: heartRateField,
  );

  expect(validation.hasWarning, isTrue);
  expect(validation.warningMessage, contains('unusually high'));
});
```

### 4. Unit Conversion Tests

**Purpose**: Verify unit conversions are accurate.

```dart
test('mmHg to kPa conversion', () {
  expect(convertPressure(760, from: 'mmHg', to: 'kPa'), closeTo(101.3, 0.1));
});

test('Fahrenheit to Celsius conversion', () {
  expect(convertTemperature(98.6, from: 'F', to: 'C'), closeTo(37.0, 0.1));
});
```

### 5. Widget Tests

**Purpose**: Verify key UI components render correctly.

**Focus Areas**:
- Calculator input form renders all fields
- Results display shows correct formatting
- Checklist items toggle correctly
- Navigation between tabs works

### 6. Integration Tests

**Purpose**: Verify end-to-end flows work correctly.

**Key Flows**:
- Complete a calculation and save to history
- View and clear history
- Complete a protocol checklist
- View feed with cached data

## Test File Organization

```
test/
├── calculators/
│   ├── ventilation_calculators_test.dart
│   ├── oxygenation_calculators_test.dart
│   ├── hemodynamics_calculators_test.dart
│   └── unit_conversion_test.dart
├── parsers/
│   ├── aarc_parser_test.dart
│   ├── nbrc_parser_test.dart
│   └── rss_parser_test.dart
├── fixtures/
│   ├── aarc_news.html
│   ├── nbrc_news.html
│   └── podcast_feed.xml
├── validation/
│   └── input_validation_test.dart
└── widgets/
    ├── calculator_form_test.dart
    └── checklist_test.dart
```

## Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/calculators/ventilation_calculators_test.dart

# Run tests with coverage
flutter test --coverage

# Run tests in verbose mode
flutter test --reporter expanded
```

## Calculator Test Matrix

| Calculator | Normal Test | Edge Cases | Units |
|------------|-------------|------------|-------|
| Minute Ventilation | ✓ | ✓ | ✓ |
| Alveolar Ventilation | ✓ | ✓ | ✓ |
| Dead Space Ratio | ✓ | ✓ | - |
| A-a Gradient | ✓ | ✓ | ✓ |
| P/F Ratio | ✓ | ✓ | - |
| Oxygen Content | ✓ | ✓ | ✓ |
| ... | ... | ... | ... |

## Continuous Integration

Tests should run on:
- Every pull request
- Before merging to main
- Nightly for integration tests

## Test Data Sources

Calculator test values derived from:
- Standard respiratory therapy textbooks
- Published clinical guidelines
- Known reference calculations

All test values should be documented with their source for verification.
