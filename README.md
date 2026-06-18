# Ploy — Bill Splitter

<p align="center">
  <img src="assets/images/ploy_logo_light.svg" alt="Ploy Logo" height="80"/>
</p>

<p align="center">
  A clean, fast, and offline-first bill splitting and expense tracking app built with Flutter.
</p>

<p align="center">
  <a href="../../releases/latest">
    <img src="https://img.shields.io/github/v/release/EveningLantern/ploy?label=latest&color=7C6AF5&style=for-the-badge" alt="Latest Release"/>
  </a>
  <a href="../../releases/latest/download/app-release.apk">
    <img src="https://img.shields.io/badge/Download-APK-F5C98A?style=for-the-badge&logo=android&logoColor=2B2260" alt="Download APK"/>
  </a>
  <img src="https://img.shields.io/badge/Flutter-3.10.7-54C5F8?style=for-the-badge&logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License"/>
</p>

---

## ⬇️ Download

| Platform | Link |
|----------|------|
| Android APK | [**Download latest release →**](https://github.com/EveningLantern/bill_splitter/releases/download/version-2.0/Ploy-version-2.0.apk) |
| All releases | [GitHub Releases](../../releases) |

> iOS build coming in a future update.

---

## Features

### 💰 Bill Tracker

- **Expense & Income Logging** — Log entries with an amount, label, and timestamp via a modal bottom sheet.
- **Running Totals** — Always-visible summary cards show total expenses and total income for the active period.
- **Reset to History** — Reset expenses or income independently; entries are archived as a history batch instead of deleted.
- **Auto-Purge History** — Batches older than 20 days are automatically removed on app start to keep storage lean.
- **Bill History Screen** — Browse all archived reset batches, sorted newest-first, with entry count and total per batch.

### 🧾 Bill Splitter

- **New Split Sessions** — Name your outing, add participants with emoji avatars, and track every expense in a guided 3-step flow (Setup → Expenses → Review).
- **Smart Settlement Calculator** — Computes the minimum number of transfers needed to settle all debts across the group.
- **Complex Splits** — Each expense tracks who paid and who it's split among — works for any scenario (dinners, rides, tickets, hotel bookings).
- **Split History** — View all past and active sessions with stats. Filter by All / Active / Settled.
- **Mark as Settled** — Toggle any session between active and settled. Delete all settled sessions at once.
- **Copy Summary** — One-tap copy of the full settlement breakdown to share via any messaging app.

### ⚙️ General

- **User Profile** — Set your name and emoji avatar, persisted locally.
- **What's New** — In-app release notes viewable from the profile screen.
- **Offline First** — All data stored on-device via Hive. No account or internet required.

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

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Releases

| Version | Date       | Highlights                                                                      |
| ------- | ---------- | ------------------------------------------------------------------------------- |
| 2.0.0   | 2026-06-18 | ✅ Bill Tracker (income/expense logging, history, auto-purge) · ✅ Full Split flow · Smart settlement engine · In-app release notes |
| 1.0.0   | 2026-06-06 | Initial release — core split flow, history, settlement calculator, user profile |

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
│   ├── profile_screen.dart      # Profile + What's New
│   └── split_steps/             # Steps 1–3 of the split flow
├── data/
│   └── release_notes.dart       # Hardcoded version changelog
├── theme/                       # AppTheme color constants + text styles
├── utils/                       # Settlement calculator logic
└── widgets/                     # Shared reusable widgets
    ├── bill_tracker_section.dart
    ├── entry_form_sheet.dart
    ├── summary_card.dart
    ├── fade_slide.dart
    └── ...
```

---

## Developer

Built by **Sayandeep** · [EveningLantern](https://github.com/EveningLantern)

---

## License

MIT
