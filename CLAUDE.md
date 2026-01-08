# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RT OneStop is a cross-platform mobile app for Respiratory Therapists built with Flutter. It provides calculators, reference values, protocols, and news feeds for RT professionals.

## Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Local Storage**: SQLite (drift) or Hive
- **Routing**: go_router
- **UI**: Material 3 with dark mode support
- **Networking**: http package with HTML/RSS parsing

## Build Commands

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Build for release
flutter build apk        # Android
flutter build ios        # iOS

# Analyze code
flutter analyze

# Format code
dart format .
```

## Architecture

### Data-Driven Calculator System

Calculators are defined as structured data (JSON or strongly-typed config), not hardcoded UI. Each calculator definition includes:
- Formula name, inputs with units, outputs with units
- Unit conversions (mmHg/kPa, mL/L, kg/lb, cm/in)
- Range validation with warnings (non-blocking)
- Clinical notes and source references

Adding a new calculator requires only adding a new definition - no UI screen changes needed.

### Module Structure

- **Calculators**: Data-driven RT equation library (~25+ formulas)
- **Reference**: Normal values for Neonatal/Pediatric/Adult populations
- **Protocols**: Step-by-step checklists (Vapotherm, MV setup, NRP/PALS/BLS/ACLS)
- **Feed**: News from AARC, NBRC, and AARC Perspectives podcast
- **History/Settings**: Calculation history, preferences, disclaimers

### Data Storage

- Calculators and reference ranges: bundled in-app for offline access
- News feeds: cached locally, requires internet to refresh
- Calculation history: local SQLite/Hive storage
- No user accounts or PHI storage

## Safety Requirements

- App-wide disclaimer required: "For educational/reference use only. Not medical advice."
- First-run disclaimer acknowledgment gate
- No copyrighted text - write original descriptions
- External links for sources
- "Report an issue" functionality

## Documentation

See `/docs` folder for:
- `PRODUCT_REQUIREMENTS.md` - screens and flows
- `DATA_MODEL.md` - calculator and reference range schemas
- `ARCHITECTURE.md` - detailed architecture decisions
- `TESTING.md` - testing strategy
