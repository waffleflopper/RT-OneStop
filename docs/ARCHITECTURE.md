# Architecture - RT OneStop

## Overview

RT OneStop follows a feature-first architecture with clean separation between data, domain, and presentation layers. The app is built with Flutter using Riverpod for state management.

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Shared core functionality
│   ├── constants/            # App-wide constants
│   ├── theme/                # Material 3 theme configuration
│   ├── router/               # go_router configuration
│   ├── services/             # Core services (storage, network)
│   └── utils/                # Utility functions
├── features/                 # Feature modules
│   ├── calculators/
│   │   ├── data/             # Calculator definitions, repository
│   │   ├── domain/           # Calculator models, computation logic
│   │   └── presentation/     # UI screens, widgets, providers
│   ├── reference/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── protocols/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── feed/
│   │   ├── data/             # Feed fetching, parsing, caching
│   │   ├── domain/
│   │   └── presentation/
│   └── settings/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/                   # Shared components
    ├── widgets/              # Reusable UI components
    ├── models/               # Shared data models
    └── providers/            # Shared Riverpod providers

assets/
└── data/                     # Bundled JSON data files
    ├── calculators.json
    ├── reference_ranges.json
    └── protocols.json

docs/                         # Documentation
test/                         # Unit and widget tests
```

## Key Architectural Decisions

### 1. Local Storage: Hive

**Decision**: Use Hive instead of SQLite/drift.

**Rationale**:
- Faster setup with no code generation required for basic use
- Excellent performance for key-value and object storage
- Pure Dart implementation (no native dependencies)
- Simpler API for the data patterns in this app
- Sufficient for storing preferences, history, and feed cache

**Trade-offs**:
- No SQL query capabilities (not needed for this app)
- Less suitable for complex relational data

### 2. Data-Driven Calculators

**Decision**: Define calculators as JSON/structured data rather than individual Dart classes.

**Rationale**:
- Adding a new calculator requires only adding data, not code
- Ensures consistency across all calculators
- Enables potential future features (remote calculator updates)
- Separates formula logic from UI

**Implementation**:
- Calculator definitions stored in `assets/data/calculators.json`
- Generic calculator engine interprets definitions
- Computation functions mapped by calculator ID for complex formulas

### 3. Feature-First Organization

**Decision**: Organize code by feature rather than by layer.

**Rationale**:
- Each feature is self-contained and easy to navigate
- Reduces coupling between features
- Easier to understand feature boundaries
- Scales well as features grow

### 4. Offline-First Design

**Decision**: Bundle all calculator and reference data locally.

**Rationale**:
- RTs often work in environments with poor connectivity
- Critical reference data must be available instantly
- Only news feeds require network access

## State Management

### Riverpod Providers

```dart
// Calculator providers
final calculatorRepositoryProvider = Provider<CalculatorRepository>(...);
final calculatorsProvider = FutureProvider<List<CalculatorDefinition>>(...);
final calculatorProvider = FutureProvider.family<CalculatorDefinition, String>(...);

// Feed providers
final feedRepositoryProvider = Provider<FeedRepository>(...);
final feedItemsProvider = FutureProvider<List<FeedItem>>(...);
final feedRefreshProvider = FutureProvider<void>(...);

// Settings providers
final preferencesProvider = StateNotifierProvider<PreferencesNotifier, UserPreferences>(...);
final historyProvider = StateNotifierProvider<HistoryNotifier, List<CalculationHistory>>(...);
```

### State Flow

1. **App Start** → Initialize Hive → Load preferences → Check disclaimer
2. **Calculator Use** → Load definition → Validate inputs → Compute → Display/save
3. **Feed Refresh** → Fetch sources → Parse HTML/RSS → Cache → Display

## Networking & Parsing

### Feed Sources

| Source | Type | Parser |
|--------|------|--------|
| AARC News | HTML | Custom HTML scraper |
| NBRC News | HTML | Custom HTML scraper |
| AARC Podcast | RSS | XML parser |

### Parsing Strategy

- Use `http` package for requests
- `html` package for HTML parsing (DOM traversal)
- `xml` package for RSS/XML parsing
- Graceful fallbacks on parse failures
- Cache parsed results in Hive

## Routing

### go_router Configuration

```dart
GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Redirect to disclaimer if not acknowledged
    if (!hasAcknowledgedDisclaimer && state.location != '/disclaimer') {
      return '/disclaimer';
    }
    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/calculators', ...),
        GoRoute(path: '/calculators/:id', ...),
        GoRoute(path: '/reference', ...),
        GoRoute(path: '/protocols', ...),
        GoRoute(path: '/protocols/:id', ...),
        GoRoute(path: '/feed', ...),
        GoRoute(path: '/settings', ...),
        GoRoute(path: '/settings/history', ...),
      ],
    ),
    GoRoute(path: '/disclaimer', ...),
  ],
)
```

## Theme

Material 3 design with:
- Dynamic color support (Android 12+)
- Light and dark mode
- Large touch targets (minimum 48dp)
- Accessible color contrast
- Consistent spacing scale

## Error Handling

- Network errors → Show cached data + error banner
- Parse errors → Log and show partial data
- Validation errors → Inline warnings (non-blocking)
- Unexpected errors → Error boundary with report option
