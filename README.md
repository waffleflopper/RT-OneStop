# RT OneStop

A cross-platform mobile application for Respiratory Therapists providing calculators, reference values, protocols, and news feeds.

## Features

### Calculators
A data-driven library of 25+ RT equations including:
- **Ventilation**: Minute ventilation, alveolar ventilation, dead space ratio, RSBI, compliance, resistance
- **Oxygenation**: A-a gradient, alveolar gas equation, P/F ratio, oxygen content/delivery
- **Hemodynamics**: MAP, CPP, cardiac output/index, SVR, PVR
- **Body Measurements**: IBW, BSA, BMI
- **Acid-Base**: Anion gap, Winter's formula, bicarbonate deficit
- **Oxygen Equipment**: Cylinder duration, FiO₂ estimation

Each calculator includes unit conversions, input validation with warnings, and clinical notes.

### Quick Reference
Normal values and ranges for:
- Neonatal, Pediatric, and Adult populations
- Vital signs, ABG values, ventilator parameters
- Hemodynamic parameters, lung volumes, electrolytes

### Protocols
Step-by-step checklists with progress tracking:
- HFNC/Vapotherm Initiation (Neonate)
- Mechanical Ventilation Setup (Adult)
- NRP, PALS, BLS, ACLS Quick Reference guides

### News Feed
Aggregated content from:
- AARC News (HTML scraping)
- NBRC News (HTML scraping)
- AARC Perspectives Podcast (RSS)

With offline caching and pull-to-refresh.

## Getting Started

### Prerequisites
- Flutter SDK 3.10+
- Dart SDK 3.0+

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd rt_onestop

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Building for Release

```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## Adding New Calculators

Calculators are defined in `assets/data/calculators.json`. Each calculator has:

```json
{
  "id": "unique_id",
  "name": "Display Name",
  "category": "Category",
  "description": "Plain-language description",
  "formula": "Mathematical formula display",
  "inputs": [
    {
      "id": "input_id",
      "label": "Input Label",
      "defaultUnit": "unit",
      "alternateUnits": [{"unit": "alt", "conversionFactor": 1.0}],
      "minValue": 0,
      "maxValue": 100,
      "warningMin": 10,
      "warningMax": 90
    }
  ],
  "outputs": [
    {
      "id": "output_id",
      "label": "Output Label",
      "unit": "unit",
      "decimalPlaces": 2,
      "interpretation": "Normal range info"
    }
  ],
  "clinicalNote": "Clinical caveats",
  "sourceUrls": ["https://..."]
}
```

Then add the calculation logic to `lib/features/calculators/domain/calculator_engine.dart`.

## Data Sources

### Feeds
- AARC News: https://www.aarc.org/all-news/ (HTML)
- NBRC News: https://www.nbrc.org/news/ (HTML)
- AARC Podcast: https://feeds.buzzsprout.com/1512487.rss (RSS)

Feed data is cached locally for offline access. Network failures are handled gracefully.

### Reference Data
All reference ranges are bundled locally in `assets/data/reference_ranges.json` with source citations.

## Architecture

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Local Storage**: Hive
- **Routing**: go_router
- **UI**: Material 3

See `/docs/ARCHITECTURE.md` for detailed architecture documentation.

## Disclaimer

**RT OneStop is for educational and reference purposes only. It does not constitute medical advice.**

Always follow your institution's protocols, physician orders, and local guidelines. The developers are not liable for clinical decisions made using this app.

## Documentation

- `/docs/PRODUCT_REQUIREMENTS.md` - Screens and user flows
- `/docs/DATA_MODEL.md` - Data schemas
- `/docs/ARCHITECTURE.md` - Technical architecture
- `/docs/TESTING.md` - Testing strategy
