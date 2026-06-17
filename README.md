# Ploy — Bill Splitter

A clean, fast, and offline-first bill splitting app built with Flutter. Ploy lets you split expenses with friends in seconds — add participants, log who paid what, and instantly see the minimum transactions needed to settle up.

---

## Features

### Bill Tracker (personal finance)

- **Expense & Income Logging** — Log individual expenses and income entries with an amount, label, and date/time via a modal bottom sheet.
- **Running Totals** — Always-visible summary cards show current total expenses and total income for the active period.
- **Reset to History** — Reset expenses or income independently; entries are archived as a history batch rather than deleted.
- **Auto-Purge History** — History batches older than 20 days are automatically removed on app start to keep storage lean.
- **Bill History Screen** — Browse all archived reset batches, sorted newest-first, with entry count and total per batch.

### Bill Splitter (group expenses)

- **New Split Sessions** — Give your outing a name, add participants with emoji avatars, and track every expense in a guided 3-step flow (Setup → Expenses → Review).
- **Smart Settlement Calculator** — Automatically computes the minimum number of transfers to settle all debts across the group.
- **Split History** — View all past and active sessions with stats (total amount split, top split buddy). Filter by All / Active / Settled.
- **Mark as Settled** — Toggle any session between active and settled. Delete all settled sessions at once.
- **Copy Summary** — One-tap copy of the full settlement breakdown to share via any messaging app.

### General

- **User Profile** — Set your name and emoji avatar, persisted locally.
- **Offline First** — All data is stored on-device using Hive. No account or internet required.

---

## Tech Stack

| Layer            | Technology                                                                    |
| ---------------- | ----------------------------------------------------------------------------- |
| Framework        | [Flutter](https://flutter.dev) (Dart)                                         |
| State Management | [Riverpod](https://riverpod.dev) (`flutter_riverpod` + `riverpod_annotation`) |
| Navigation       | [go_router](https://pub.dev/packages/go_router)                               |
| Local Storage    | [Hive](https://pub.dev/packages/hive) + `hive_flutter`                        |
| Preferences      | [shared_preferences](https://pub.dev/packages/shared_preferences)             |
| Fonts            | [google_fonts](https://pub.dev/packages/google_fonts)                         |
| ID Generation    | [uuid](https://pub.dev/packages/uuid)                                         |
| Code Generation  | `build_runner`, `hive_generator`, `riverpod_generator`                        |

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.10.7`
- Dart SDK `^3.10.7`

### Run locally

```bash
flutter pub get
flutter run
```

### Build APK

```bash
flutter build apk --release
```

The output APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

---

## Releases

| Version | Date       | Notes                                                                           |
| ------- | ---------- | ------------------------------------------------------------------------------- |
| 1.0.0   | 2026-06-06 | Initial release — core split flow, history, settlement calculator, user profile |

> APK downloads will be available in [GitHub Releases](../../releases) once published.

---

## Project Structure

```
lib/
├── main.dart                    # App entry point, Hive init + adapter registration
├── app.dart                     # Root widget, router config (go_router)
├── models/                      # Hive data models
│   ├── person.dart              # Splitter: participant
│   ├── expense.dart             # Splitter: expense record
│   ├── split_session.dart       # Splitter: session snapshot
│   ├── bill_entry.dart          # Bill: BillEntryType enum + BillEntry (typeIds 4/5)
│   └── history_batch.dart       # Bill: reset history batch (typeId 6)
├── providers/                   # Riverpod providers
│   ├── history_provider.dart    # Splitter: session history
│   ├── active_session_provider.dart
│   ├── session_provider.dart
│   ├── settlement_provider.dart
│   ├── profile_provider.dart    # User profile
│   └── bill_provider.dart       # Bill: BillState AsyncNotifier
├── screens/                     # UI screens
│   ├── home_screen.dart         # Tab toggle: Bill | Splitter
│   ├── bill_history_screen.dart # Bill: archived reset batches
│   ├── split_now_screen.dart
│   ├── history_screen.dart      # Splitter: session history
│   ├── session_detail_screen.dart
│   ├── profile_screen.dart
│   └── split_steps/             # Steps 1-3 of the split flow
├── theme/                       # AppTheme color constants + text styles
├── utils/                       # Settlement calculator logic
└── widgets/                     # Shared reusable widgets
    ├── bill_tracker_section.dart # Bill: root section widget
    ├── entry_form_sheet.dart     # Bill: add expense/income modal sheet
    ├── summary_card.dart         # Bill: total expense/income card
    ├── fade_slide.dart
    └── ...                      # Splitter widgets (unchanged)
```

---

## License

MIT
