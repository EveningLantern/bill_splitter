# Implementation Plan: Bill Tracker

## Overview

Extend the Ploy app with a personal finance "Bill" section alongside the existing Splitter. Implementation proceeds in layers: data models and Hive adapters → provider state → UI widgets → HomeScreen integration → routing — each step wiring into the next with no orphaned code.

---

## Tasks

- [x] 1. Create Bill Tracker data models and Hive adapters
  - [x] 1.1 Create `lib/models/bill_entry.dart` with `BillEntryType` enum (typeId 4) and `BillEntry` HiveObject (typeId 5)
    - Define `@HiveType(typeId: 4)` enum with `@HiveField` on both values
    - Define `@HiveType(typeId: 5)` class with fields: id (0), type (1), amount (2), name (3), dateTime (4)
    - Add UUID-based `id` default and `DateTime.now()` default in constructor
    - _Requirements: 8.1, 3.1, 4.1_
  - [x] 1.2 Create `lib/models/history_batch.dart` with `HistoryBatch` HiveObject (typeId 6)
    - Define `@HiveType(typeId: 6)` class with fields: id (0), type (1), entries (2), resetAt (3)
    - Add `totalAmount` and `entryCount` getters
    - Store `resetAt` as UTC timestamp
    - _Requirements: 8.2, 5.3, 6.3, 7.2_
  - [x] 1.3 Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate `bill_entry.g.dart` and `history_batch.g.dart`
    - Verify both `.g.dart` files are generated without errors
    - _Requirements: 8.1, 8.2_

- [x] 2. Implement `BillState` and `Bill` AsyncNotifier provider
  - [x] 2.1 Create `lib/providers/bill_provider.dart` with the `BillState` immutable value object
    - Define all fields: `expenses`, `incomes`, `history`, `totalExpense`, `totalIncome`, `errorMessage`
    - Implement `copyWith` with nullable `errorMessage` clearing semantics
    - _Requirements: 9.1, 9.2_
  - [ ]\* 2.2 Write property test for `BillState` total consistency (Property 1)
    - **Property 1: Total Consistency** — `totalExpense` equals fold-sum of `expenses`; `totalIncome` equals fold-sum of `incomes`
    - **Validates: Requirements 2.1, 2.2, 9.1**
    - Place in `test/bill_tracker/bill_state_test.dart`
  - [x] 2.3 Implement the `Bill` AsyncNotifier in `bill_provider.dart`
    - Implement `build()`: open boxes, call `_purgeOldBatches()`, return `_buildState()`, subscribe to `_entriesBox.watch()`
    - Implement `addEntry(BillEntry)`: write to `_entriesBox`, call `_refresh()`, rethrow on failure with `_setError`
    - Implement `resetExpenses()`: create batch, write to `_historyBox`, delete from `_entriesBox`, rollback on failure
    - Implement `resetIncomes()`: same pattern as `resetExpenses()` for income entries
    - Implement `_purgeOldBatches()`: date-only comparison, `daysDiff > 20`, log and skip per-batch errors
    - Implement `_buildState()`, `_refresh()`, `_setError()`, `_total()`, `_dateOnly()` helpers
    - _Requirements: 9.1, 9.2, 9.5, 5.3, 5.4, 6.3, 6.4, 7.3, 8.3_
  - [x] 2.4 Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate `bill_provider.g.dart`
    - _Requirements: 9.1_
  - [ ]\* 2.5 Write property test for reset expense isolation (Property 3)
    - **Property 3: Reset Expense Isolation** — after `resetExpenses()`, `state.incomes` and `state.totalIncome` are unchanged
    - **Validates: Requirements 5.7**
    - Place in `test/bill_tracker/bill_provider_test.dart`
  - [ ]\* 2.6 Write property test for reset income isolation (Property 4)
    - **Property 4: Reset Income Isolation** — after `resetIncomes()`, `state.expenses` and `state.totalExpense` are unchanged
    - **Validates: Requirements 6.7**
    - Place in `test/bill_tracker/bill_provider_test.dart`
  - [ ]\* 2.7 Write property test for auto-purge threshold (Property 5)
    - **Property 5: Auto-Purge Threshold** — batches with `daysDiff > 20` are absent; batches with `daysDiff ≤ 20` are present after `build()`
    - **Validates: Requirements 7.3**
    - Place in `test/bill_tracker/bill_provider_test.dart`
  - [ ]\* 2.8 Write property test for non-negative totals (Property 8)
    - **Property 8: Non-Negative Totals** — `totalExpense ≥ 0.0` and `totalIncome ≥ 0.0` for any valid `BillState`
    - **Validates: Requirements 2.4, 2.5, 9.1**
    - Place in `test/bill_tracker/bill_state_test.dart`
  - [ ]\* 2.9 Write property test for history batch type isolation (Property 9)
    - **Property 9: History Batch Type Isolation** — `resetExpenses()` always creates a batch with `type = expense`; `resetIncomes()` always creates `type = income`
    - **Validates: Requirements 5.3, 6.3**
    - Place in `test/bill_tracker/bill_provider_test.dart`

- [x] 3. Register Hive adapters and open boxes in `main.dart`
  - [x] 3.1 Update `lib/main.dart` to import `bill_entry.dart` and `history_batch.dart`, register `BillEntryTypeAdapter` (typeId 4), `BillEntryAdapter` (typeId 5), `HistoryBatchAdapter` (typeId 6), and open `bill_entries` and `bill_history` boxes
    - _Requirements: 8.1, 8.2, 8.6_

- [x] 4. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Implement shared UI widgets
  - [x] 5.1 Create `lib/widgets/summary_card.dart`
    - `SummaryCard` StatelessWidget with `label`, `amount`, `accentColor`, `icon` parameters
    - Format amount as `₹X.XX` with `toStringAsFixed(2)`
    - Use `AppTheme.surface` background, `BorderRadius.circular(AppTheme.cardRadius)` shape
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 10.1, 10.3_
  - [x] 5.2 Create `lib/widgets/entry_form_sheet.dart` with `EntryFormSheet` and `EntryFormMode` enum
    - `ConsumerStatefulWidget` holding `_amountController`, `_nameController`, `_selectedDateTime`, `_amountError`, `_nameError`, `_isSubmitting`
    - Static `EntryFormSheet.show(context, mode)` launcher using `showModalBottomSheet(isScrollControlled: true)`
    - Build form with amount field, name/source field (label changes by mode), and `_DateTimePicker` widget
    - Implement `_submit()`: trim & validate both fields with inline error display, create `BillEntry`, call `addEntry`, `Navigator.pop()` on success, show SnackBar on failure
    - Implement `_DateTimePicker`: chain `showDatePicker` → `showTimePicker`, update `_selectedDateTime`
    - Pre-populate `_selectedDateTime` with `DateTime.now()` truncated to the minute
    - _Requirements: 3.1–3.11, 4.1–4.11, 10.5_
  - [ ]\* 5.3 Write property test for amount validation boundary (Property 6)
    - **Property 6: Amount Validation Boundary** — amounts in `[0.01, 999_999_999.99]` are valid; amounts outside are invalid
    - **Validates: Requirements 3.3, 4.3**
    - Place in `test/bill_tracker/entry_form_test.dart`
  - [ ]\* 5.4 Write property test for name length boundary (Property 7)
    - **Property 7: Name Length Boundary** — names of length 1–100 are valid; length 0 or > 100 are invalid
    - **Validates: Requirements 3.4, 4.4**
    - Place in `test/bill_tracker/entry_form_test.dart`

- [x] 6. Implement `BillTrackerSection` and `BillHistoryScreen`
  - [x] 6.1 Create `lib/widgets/bill_tracker_section.dart`
    - `BillTrackerSection` ConsumerWidget watching `billProvider`; handle loading/error/data states
    - `_BillContent` renders summary cards row, `_SectionHeader` + entry list (or placeholder) for expenses, same for income, and `_HistoryButton`
    - `_SectionHeader` shows section title, Add icon button (always enabled), Reset text button (disabled/null `onReset` when list is empty)
    - `_EntryList` renders entries as `Column` of `_EntryTile` items wrapped in `FadeSlide`
    - `_EntryTile` shows icon (red downward / accentWarm upward), name, `₹X.XX` amount, formatted date-time
    - Empty state: render `_EmptyPlaceholder` text widget; do not render empty `ListView`
    - Reset tap: show `showDialog` confirmation with "Confirm" and "Cancel"; on confirm call `ref.read(billProvider.notifier).resetExpenses/resetIncomes()`; show SnackBar on error
    - `_HistoryButton` navigates to `/bill-history`
    - _Requirements: 2.1–2.9, 5.1–5.7, 6.1–6.7, 7.7, 10.1, 10.3, 10.4, 10.6, 10.7_
  - [ ]\* 6.2 Write unit tests for `BillTrackerSection` empty-state and loading-state rendering
    - Test loading state shows `CircularProgressIndicator`
    - Test empty expense/income lists show placeholder text, not empty `ListView`
    - _Requirements: 2.8, 2.9, 9.5_
  - [x] 6.3 Create `lib/screens/bill_history_screen.dart`
    - `BillHistoryScreen` ConsumerWidget watching `billProvider`, route `/bill-history`
    - `AppBar` with title "Bill History", `AppTheme.primaryBg` background
    - Show batches sorted newest-first; each `_BatchCard` shows type chip, reset date (`dd MMM yyyy, HH:mm`), entry count, total `₹X.XX`
    - Empty state: `Center(Text('No history yet'))`; error state: `Center(Text('Unable to load history'))`
    - Animate items with `FadeSlide(delay: Duration(milliseconds: i * 60))`
    - _Requirements: 7.1, 7.5, 7.7, 10.1, 10.3, 10.7_

- [x] 7. Add `/bill-history` route in `app.dart`
  - [x] 7.1 Update `lib/app.dart` to import `BillHistoryScreen` and add a `GoRoute` for `/bill-history` using the `_slideTransition` page builder
    - _Requirements: 7.1_

- [x] 8. Convert `HomeScreen` and integrate tab toggle
  - [x] 8.1 Convert `lib/screens/home_screen.dart` from `ConsumerWidget` to `ConsumerStatefulWidget`; add `_BillTab` enum and `_activeTab` state field defaulting to `_BillTab.bill`
    - _Requirements: 1.1, 1.3_
  - [x] 8.2 Add `_TabToggle` private widget to `home_screen.dart`
    - `_TabToggle` is stateless; receives `activeTab` and `onTabChanged` callback
    - `_TabLabel` helper: `ConstrainedBox(minWidth: 44, minHeight: 44)` wrapping `GestureDetector` with `headlineMedium` bold text
    - Active label: `AppTheme.textPrimary` (white); inactive: `AppTheme.textSecondary` (grey 0xFFB8B4E8)
    - Separator: `Text(' | ')` in `textSecondary` style
    - _Requirements: 1.2, 1.3, 1.4, 1.5, 1.6, 1.7_
  - [x] 8.3 Update `_TopBar` in `home_screen.dart` to accept `activeTab` and `onTabChanged` parameters; replace `Text('Bill Splitter')` with `_TabToggle`
    - _Requirements: 1.1, 1.6_
  - [x] 8.4 Update `_HomeScreenState.build()` to conditionally render `BillTrackerSection` when `_activeTab == _BillTab.bill`, or the existing Splitter widgets when `_activeTab == _BillTab.splitter`; show FAB only on Splitter tab
    - Import `BillTrackerSection` and wrap in `FadeSlide(delay: _d1)`
    - _Requirements: 1.4, 1.5, 1.8_
  - [x] 8.5 Write unit tests for `HomeScreen` tab switching
    - Test default tab is Bill, tapping Splitter switches content, tapping Bill switches back
    - Test FAB is present on Splitter tab and absent on Bill tab
    - _Requirements: 1.3, 1.4, 1.5_

- [-] 9. Implement round-trip persistence property test (Property 2)
  - [-]\* 9.1 Write property test for `BillEntry` round-trip persistence (Property 2)
    - **Property 2: Round-Trip Persistence** — a `BillEntry` written to and read from Hive has all fields (`id`, `type`, `amount`, `name`, `dateTime`) equal to the original
    - **Validates: Requirements 8.5**
    - Place in `test/bill_tracker/persistence_test.dart`; use in-memory Hive configuration

- [ ] 10. Implement state atomicity property test (Property 10)
  - [ ]\* 10.1 Write property test for state atomicity on reset failure (Property 10)
    - **Property 10: State Atomicity on Reset Failure** — if reset fails at any point, resulting state is identical to pre-reset state (no partial update observable)
    - **Validates: Requirements 5.4, 6.4**
    - Place in `test/bill_tracker/bill_provider_test.dart`; inject a failing Hive mock

- [ ] 11. Final checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

---

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- The design already specifies all Dart/Flutter code — implementation tasks reference the design document for exact signatures
- Run `flutter pub run build_runner build --delete-conflicting-outputs` after any model or provider change
- Property tests validate universal correctness properties; unit tests validate specific examples and edge cases

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2"] },
    { "id": 1, "tasks": ["1.3"] },
    { "id": 2, "tasks": ["2.1", "3.1"] },
    { "id": 3, "tasks": ["2.2", "2.3"] },
    { "id": 4, "tasks": ["2.4", "2.8"] },
    { "id": 5, "tasks": ["2.5", "2.6", "2.7", "2.9", "5.1", "5.2"] },
    { "id": 6, "tasks": ["5.3", "5.4", "6.1", "6.3"] },
    { "id": 7, "tasks": ["6.2", "7.1"] },
    { "id": 8, "tasks": ["8.1"] },
    { "id": 9, "tasks": ["8.2", "8.3"] },
    { "id": 10, "tasks": ["8.4"] },
    { "id": 11, "tasks": ["8.5", "9.1", "10.1"] }
  ]
}
```
