# Product Requirements - RT OneStop

## Overview

RT OneStop is a cross-platform mobile application for Respiratory Therapists providing calculators, reference values, protocols, and news feeds.

## Screens & Navigation

### Bottom Navigation Tabs
1. **Calculators** - RT equation library
2. **Reference** - Normal values quick reference
3. **Protocols** - Step-by-step checklists
4. **Feed** - News and podcasts
5. **Settings** - App configuration and history

---

## 1. Calculators Module

### Calculator List Screen
- Searchable list of all calculators
- Grouped by category (Ventilation, Oxygenation, Hemodynamics, etc.)
- Recent/favorites section at top
- Tap to open calculator detail

### Calculator Detail Screen
- Formula name and category badge
- Input fields with:
  - Labels and units
  - Unit conversion toggles (e.g., mmHg ↔ kPa)
  - Range validation with warnings (non-blocking)
- Calculate button
- Results display with units
- Actions:
  - Copy result to clipboard
  - Save to history
  - Info button → opens info panel

### Calculator Info Panel (Bottom Sheet)
- Plain-language description
- Clinical caveats/limitations
- Source links (external)

---

## 2. Reference Module

### Reference List Screen
- Segmented control: Neonatal | Pediatric | Adult
- Searchable list of reference categories
- Favorites toggle
- Tap to expand/view details

### Reference Detail View
- Category header
- Table/list of normal ranges
- Age-specific subdivisions where applicable
- Last reviewed date
- Source citations with links

### Reference Categories
- Vital Signs (HR, RR, BP, SpO2)
- Blood Gas Values
- Ventilator Starting Parameters
- Lung Volumes
- Other RT-specific values

---

## 3. Protocols Module

### Protocols List Screen
- List of available protocols/checklists
- Icon indicating type (procedure, emergency, etc.)
- Disclaimer banner

### Protocol Detail Screen (Checklist)
- Protocol title and disclaimer
- Step-by-step checklist items
- Each item:
  - Checkbox for "done" state
  - Short instruction text
  - Optional note field (expandable)
- Progress indicator
- Reset button

### Available Protocols (MVP)
- HFNC/Vapotherm Initiation (Neonate)
- Mechanical Ventilation Setup (Adult)
- NRP Quick Reference
- PALS Quick Reference
- BLS Quick Reference
- ACLS Quick Reference

---

## 4. Feed Module

### Feed List Screen
- Tabs or filter: All | AARC | NBRC | Podcast
- Pull-to-refresh
- List of feed items:
  - Title
  - Source badge
  - Date
  - Short snippet
- Tap to open detail/link

### Feed Sources
- AARC All News (https://www.aarc.org/all-news/) - HTML scrape
- NBRC News (https://www.nbrc.org/news/) - HTML scrape
- AARC Perspectives Podcast (RSS feed)

### Offline Behavior
- Cache last fetched results
- Show cached data when offline
- Display "last updated" timestamp
- Graceful error handling

---

## 5. Settings Module

### Settings Screen
- **Disclaimer** - View full disclaimer text
- **Default Units** - Metric/Imperial preference
- **Theme** - Dark mode toggle (or follow system)
- **Calculation History** - View/clear saved calculations
- **Clear Cache** - Clear feed cache
- **Refresh Feeds** - Manual refresh
- **About** - App version, credits
- **Report Issue** - Email link

### History Screen
- List of saved calculations
- Each entry shows:
  - Calculator name
  - Date/time
  - Inputs and results
- Swipe to delete
- Clear all button

---

## First-Run Experience

### Disclaimer Gate
- Modal/full-screen on first launch
- Disclaimer text:
  > "RT OneStop is for educational and reference purposes only. It does not constitute medical advice. Always follow your institution's protocols, physician orders, and local guidelines. The developers are not liable for clinical decisions made using this app."
- "I Understand" button required to proceed
- Disclaimer accessible anytime from Settings

---

## User Flows

### Calculate Flow
1. User taps Calculators tab
2. User searches or browses for calculator
3. User taps calculator
4. User enters inputs (with unit selection)
5. User taps Calculate
6. Results displayed with option to copy/save

### Reference Lookup Flow
1. User taps Reference tab
2. User selects population (Neo/Peds/Adult)
3. User searches or browses categories
4. User views reference values with sources

### Protocol Use Flow
1. User taps Protocols tab
2. User sees disclaimer banner
3. User selects protocol
4. User works through checklist, marking items done
5. User can add notes to items
6. User can reset checklist

### News Reading Flow
1. User taps Feed tab
2. User browses or filters news items
3. User taps item
4. Item opens in in-app browser (external URL)
