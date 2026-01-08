You are Claude Code acting as a senior product engineer + tech lead. Build a cross-platform mobile app called “RT OneStop” for Respiratory Therapists.

GOALS (MVP)

1. “Calculators” — a one-stop shop of RT equations (as a structured library, not hardcoded UI).

   - Use Respiratory Therapy Zone’s “Respiratory Formulas, Calculations, and Equations” page ONLY as a checklist of which formulas to include (do NOT copy their explanatory text or examples verbatim). Source checklist: https://www.respiratorytherapyzone.com/respiratory-therapy-formulas-calculations/
   - Each calculator must:
     - Show formula name, inputs with units, output(s) with units
     - Provide unit handling + conversions where reasonable (mmHg/kPa, mL/L, kg/lb, cm/in, etc.)
     - Validate ranges and warn on implausible inputs (don’t block, warn)
     - Offer “copy result” and “save calculation” to history
     - Have “info” panel: short plain-language description + clinical caveat + link(s) to source(s)
   - Architect calculators as data-driven definitions (JSON or strongly-typed config) so adding a new formula does not require editing UI screens.

2. “Normal Values / Quick Reference”

   - Provide cheat sheets for Neonatal, Pediatric, Adult:
     - Normal HR, RR, BP ranges, SpO2 targets (where appropriate), common ventilator starting ranges, and other key RT quick values.
   - IMPORTANT: This is reference only; include disclaimers and do not present as medical advice.
   - Structure reference ranges as a local data file with citations/links and “last reviewed” metadata.
   - Build a clean UI: segmented control (Neo/Peds/Adult), searchable list, favorites.

3. “Protocols / Quick Start”

   - Step-by-step quick start guides (checklists) for:
     - Starting a neonate on Vapotherm / HFNC (high-level workflow; do not claim device-specific settings are universally correct)
     - Starting an adult on mechanical ventilation (initial setup checklist; generic)
     - NRP / PALS / BLS / ACLS cheat sheets (high-level memory aid format)
   - Each checklist item should be short, tappable, and support a “done” state. Add a note field per checklist.
   - Add strong disclaimers + require first-run acknowledgment before using protocols.

4. “News / Feed”
   - Display latest items from:
     - AARC “All News” page: https://www.aarc.org/all-news/
     - NBRC “News” page: https://www.nbrc.org/news/
   - Also include AARC Perspectives podcast RSS: https://feeds.buzzsprout.com/1512487.rss
   - Implement as:
     - Serverless/simple in-app fetch + parse (HTML scraping for pages without RSS is acceptable for MVP; do best-effort parsing)
     - Caching + offline view of last fetched results
     - Show title, date, source, short snippet; open original link in in-app browser
   - Make network failures graceful.

PLATFORM / TECH CHOICES

- Default to Flutter (Dart) for iOS/Android.
- State management: Riverpod (or a simple provider pattern if you prefer). Keep it consistent.
- Local storage: SQLite (via drift) OR Hive. Choose one and explain why in docs.
- Networking: http + robust parsing (html parser / xml for RSS).
- Routing: go_router.
- UI: Material 3; clean, fast, accessible, large touch targets; support dark mode.

SAFETY / LEGAL / CONTENT RULES (NON-NEGOTIABLE)

- Add app-wide disclaimer: “For educational/reference use only. Not medical advice. Follow local protocols and provider orders.”
- First run: require acknowledging disclaimer to proceed.
- Avoid copying copyrighted text. Write original descriptions. Use external links for sources.
- Store no PHI. No patient identifiers anywhere.
- Add “Report an issue” link (email placeholder).

DELIVERABLES
A) Codebase that builds and runs with sensible defaults (no paid keys required).
B) A README.md that includes:

- App purpose + modules
- How to run
- How calculators are defined/added
- Data source notes for feeds + limitations
- Disclaimer language
  C) A /docs folder containing:
- PRODUCT_REQUIREMENTS.md (screens + flows)
- DATA_MODEL.md (calculator schema, reference ranges schema)
- ARCHITECTURE.md
- TESTING.md
  D) Tests:
- Unit tests for at least 15 calculators (golden input/output)
- Parser tests for RSS + HTML feed extraction
  E) UX:
- Tabs: Calculators | Reference | Protocols | Feed | History/Settings
- Settings: disclaimer view, units default, dark mode toggle (or follow system), “clear history”, “refresh feeds”, “about”.

WORKFLOW INSTRUCTIONS

1. Start by creating the Flutter project and folder structure.
2. Create the docs first (minimal but clear), then implement iteratively.
3. Implement calculator engine + schema before building all screens.
4. Create at least 25 calculators in MVP (more is great if time permits), prioritized:
   - Minute ventilation, alveolar ventilation, dead space (Vd/Vt)
   - A-a gradient / alveolar gas equation (short form), P/F ratio
   - Oxygen cylinder duration, liquid O2 duration (if included)
   - MAP, compliance, resistance (if included)
   - Any other commonly used RT formulas from the checklist page.
5. For each calculator, include: name, inputs, computation, units, and a short “clinical note” (original).
6. Keep commits small and logical.

OUTPUT FORMAT

- Do the work directly: create files, write code, and show key diffs.
- When you make a decision (storage choice, parsing approach), document it in /docs.
- If you need to ask questions, ask at most 5, but DO NOT block progress—make reasonable assumptions and proceed.

ASSUMPTIONS (use unless contradicted)

- Users want fast offline access; calculators and reference ranges are bundled in-app.
- News requires internet but caches last results.
- No login/account required.

Now build the MVP.
