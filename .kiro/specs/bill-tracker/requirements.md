# Requirements Document

## Introduction

The Ploy app currently contains a Bill Splitter section for splitting expenses among friends. This feature extends the app by adding a second section called **Bill** — a personal finance tracker that lets users log individual income and expense entries, view running totals for each, reset either category to history, and have that history auto-purge after 20 days. The existing Bill Splitter section must remain completely unchanged. The top-of-screen heading becomes a two-tab toggle ("Bill" | "Splitter") that switches between the two sections.

## Glossary

- **Bill_Tracker**: The new personal finance section of the Ploy app.
- **Splitter**: The existing Bill Splitter section of the Ploy app; must not be modified.
- **Entry**: A single financial record consisting of an amount, a label (product name or income source), and a timestamp (date and time).
- **Expense_Entry**: An Entry that represents money spent; always a positive number stored internally.
- **Income_Entry**: An Entry that represents money received; always a positive number stored internally.
- **Tab_Toggle**: The interactive heading bar at the top of the app containing two tab labels — "Bill" and "Splitter" — that switch the visible section.
- **Active_Tab**: The currently selected tab; rendered with white text.
- **Inactive_Tab**: The tab not currently selected; rendered with grey text.
- **Total_Expense**: The running sum of all Expense_Entry amounts in the current active period.
- **Total_Income**: The running sum of all Income_Entry amounts in the current active period.
- **Reset**: The action of clearing all entries of one type (expenses or income) from the active period and sending them to History.
- **History**: The archived store of entries that were reset; persisted in Hive for up to 20 days.
- **Hive_Box**: A named Hive persistent storage box used for long-term app data; distinct from cache or temporary storage.
- **Bill_Provider**: The Riverpod provider responsible for Bill_Tracker state, including entries, totals, and history operations.
- **Entry_Form**: The bottom sheet or modal used to add a new Expense_Entry or Income_Entry.

---

## Requirements

### Requirement 1: Tab Toggle Navigation

**User Story:** As a user, I want a "Bill | Splitter" toggle at the top of the app, so that I can switch between personal finance tracking and bill splitting without leaving the home screen.

#### Acceptance Criteria

1. THE Tab_Toggle SHALL replace the existing "Bill Splitter" text heading in the top bar of the HomeScreen, occupying the same layout slot as the prior heading text block.
2. THE Tab_Toggle SHALL display exactly two tappable labels: "Bill" on the left and "Splitter" on the right, rendered side-by-side with a separator character (" | ") or equivalent visual divider between them.
3. WHEN the app first renders the HomeScreen, THE Tab_Toggle SHALL default to "Bill" as the Active_Tab, render the "Bill" label in white (Color 0xFFFFFFFF), and render the "Splitter" label in grey (Color 0xFFB8B4E8).
4. WHEN the user taps "Bill", THE Tab_Toggle SHALL set "Bill" as the Active_Tab, render the Bill_Tracker section below the top bar, render "Bill" in white (Color 0xFFFFFFFF), and render "Splitter" in grey (Color 0xFFB8B4E8).
5. WHEN the user taps "Splitter", THE Tab_Toggle SHALL set "Splitter" as the Active_Tab, render the existing Splitter section below the top bar, render "Splitter" in white (Color 0xFFFFFFFF), and render "Bill" in grey (Color 0xFFB8B4E8).
6. THE Tab_Toggle SHALL occupy the same vertical height and horizontal start position as the existing "Bill Splitter" heading block, using headlineMedium text style (bold, as defined in AppTheme) for both labels so the top bar height does not change.
7. THE Tab_Toggle SHALL be wrapped in a widget whose hit-test area for each label covers at least 44×44 logical pixels to meet minimum tap-target size.
8. THE Splitter section SHALL remain completely unmodified in layout, widget tree, provider state, and navigation routes when the Tab_Toggle switches to "Splitter".

---

### Requirement 2: Bill Tracker Home View

**User Story:** As a user, I want to see my total expenses and total income at a glance when I open the Bill section, so that I always know my current financial position.

#### Acceptance Criteria

1. WHILE the "Bill" tab is the Active_Tab, THE Bill_Tracker SHALL display a Total_Expense summary card showing the sum of all Expense_Entry amounts that have not yet been reset (i.e., belong to the current active period).
2. WHILE the "Bill" tab is the Active_Tab, THE Bill_Tracker SHALL display a Total_Income summary card showing the sum of all Income_Entry amounts that have not yet been reset.
3. THE Total_Expense card and the Total_Income card SHALL be rendered as two separate, side-by-side or stacked containers; neither card SHALL include a combined net figure.
4. THE Total_Expense card SHALL display the amount in the format "₹X.XX" (two decimal places, preceded by the ₹ symbol); WHEN no active Expense_Entry exists, THE card SHALL display "₹0.00".
5. THE Total_Income card SHALL display the amount in the format "₹X.XX" (two decimal places, preceded by the ₹ symbol); WHEN no active Income_Entry exists, THE card SHALL display "₹0.00".
6. WHEN at least one active Expense_Entry exists, THE Bill_Tracker SHALL render a scrollable list of all active Expense_Entry items, each showing the entry's name, amount formatted as "₹X.XX", and date-time, positioned below the summary cards.
7. WHEN at least one active Income_Entry exists, THE Bill_Tracker SHALL render a scrollable list of all active Income_Entry items, each showing the entry's name, amount formatted as "₹X.XX", and date-time, positioned below or adjacent to the expense list.
8. WHEN the active Expense_Entry list is empty, THE Bill_Tracker SHALL render a non-empty text placeholder (e.g., "No expenses yet") in place of the expense list and SHALL NOT render an empty ListView widget for expenses.
9. WHEN the active Income_Entry list is empty, THE Bill_Tracker SHALL render a non-empty text placeholder (e.g., "No income yet") in place of the income list and SHALL NOT render an empty ListView widget for income.

---

### Requirement 3: Add Expense Entry

**User Story:** As a user, I want to log an expense with an amount and product name, so that I can track what I spend money on.

#### Acceptance Criteria

1. THE Bill_Tracker SHALL provide an "Add Expense" action (button or FAB) that, when tapped, opens the Entry_Form in expense mode.
2. WHEN the Entry_Form opens in expense mode, THE Entry_Form SHALL present: (a) a numeric amount field accepting decimal input, (b) a text field labelled "Product / Item name", and (c) a date-time picker widget; all three SHALL be visible and tappable before the submit action is enabled.
3. THE Entry_Form SHALL accept amount values in the range 0.01 to 999,999,999.99 (inclusive); values outside this range SHALL be treated as invalid.
4. THE Entry_Form SHALL accept item name values of 1 to 100 characters (inclusive); an empty string or a string exceeding 100 characters SHALL be treated as invalid.
5. WHEN the Entry_Form opens, THE Entry_Form SHALL pre-populate the date-time picker with the current device date and time (rounded to the minute).
6. WHEN the user selects a new date or time via the picker, THE Entry_Form SHALL update the displayed value to the user's selection immediately.
7. WHEN the user submits the Entry_Form with a valid amount and a valid item name, THE Bill_Provider SHALL persist the new Expense_Entry to the Hive_Box and then emit an updated state that includes the entry in the active expense list and the recalculated Total_Expense.
8. IF the Hive write fails during submission, THEN THE Bill_Provider SHALL not update in-memory state and SHALL surface an error message in the UI indicating the entry was not saved.
9. IF the user submits the Entry_Form with an amount outside the valid range, THEN THE Entry_Form SHALL display an inline error below the amount field and SHALL keep the form open with all field values preserved.
10. IF the user submits the Entry_Form with an item name that is empty or exceeds 100 characters, THEN THE Entry_Form SHALL display an inline error below the name field and SHALL keep the form open with all field values preserved.
11. WHEN a new Expense_Entry is added and persisted successfully, THE Bill_Tracker SHALL display the updated Total_Expense within 1 second of the Hive write completing, and THE Entry_Form SHALL dismiss automatically.

---

### Requirement 4: Add Income Entry

**User Story:** As a user, I want to log an income with an amount and source name, so that I can track money coming in.

#### Acceptance Criteria

1. THE Bill_Tracker SHALL provide an "Add Income" action (button or FAB) that, when tapped, opens the Entry_Form in income mode.
2. WHEN the Entry_Form opens in income mode, THE Entry_Form SHALL present: (a) a numeric amount field accepting decimal input, (b) a text field labelled "Income source", and (c) a date-time picker widget; all three SHALL be visible and tappable before the submit action is enabled.
3. THE Entry_Form SHALL accept amount values in the range 0.01 to 999,999,999.99 (inclusive); values outside this range SHALL be treated as invalid.
4. THE Entry_Form SHALL accept source name values of 1 to 100 characters (inclusive); an empty string or a string exceeding 100 characters SHALL be treated as invalid.
5. WHEN the Entry_Form opens, THE Entry_Form SHALL pre-populate the date-time picker with the current device date and time (rounded to the minute).
6. WHEN the user selects a new date or time via the picker, THE Entry_Form SHALL update the displayed value to the user's selection immediately.
7. WHEN the user submits the Entry_Form with a valid amount and a valid source name, THE Bill_Provider SHALL persist the new Income_Entry to the Hive_Box and then emit an updated state that includes the entry in the active income list and the recalculated Total_Income.
8. IF the Hive write fails during submission, THEN THE Bill_Provider SHALL not update in-memory state and SHALL surface an error message in the UI indicating the entry was not saved.
9. IF the user submits the Entry_Form with an amount outside the valid range, THEN THE Entry_Form SHALL display an inline error below the amount field and SHALL keep the form open with all field values preserved.
10. IF the user submits the Entry_Form with a source name that is empty or exceeds 100 characters, THEN THE Entry_Form SHALL display an inline error below the name field and SHALL keep the form open with all field values preserved.
11. WHEN a new Income_Entry is added and persisted successfully, THE Bill_Tracker SHALL display the updated Total_Income within 1 second of the Hive write completing, and THE Entry_Form SHALL dismiss automatically.

---

### Requirement 5: Reset Expenses

**User Story:** As a user, I want to reset my expenses to zero and have the old data sent to history, so that I can start a fresh expense tracking period without losing past records.

#### Acceptance Criteria

1. THE Bill_Tracker SHALL display a "Reset Expenses" button in the expenses section; WHEN the active Expense_Entry list is empty, THE button SHALL be disabled (non-interactive) and visually dimmed.
2. WHEN the user taps the enabled "Reset Expenses" button, THE Bill_Tracker SHALL present a modal confirmation dialog containing a descriptive warning message (e.g., "This will move all expenses to history") and two explicit actions: "Confirm" and "Cancel".
3. WHEN the user taps "Confirm" in the reset dialog, THE Bill_Provider SHALL create a History batch record containing a snapshot of all current active Expense_Entry items and the UTC timestamp of the moment the user tapped "Confirm".
4. WHEN the user taps "Confirm" in the reset dialog, THE Bill_Provider SHALL persist the History batch to the "bill_history" Hive_Box AND clear the active Expense_Entry list from the "bill_entries" Hive_Box in a single logical operation; IF either write fails, THEN THE Bill_Provider SHALL preserve the prior state unchanged and display an error message in the UI.
5. WHEN the reset completes successfully, THE Bill_Tracker SHALL display Total_Expense as "₹0.00" and render the expense empty-state placeholder within 1 second.
6. WHEN the user taps "Cancel" in the reset dialog, THE Bill_Provider SHALL leave the active Expense_Entry list, Total_Expense, and all History data unchanged.
7. WHEN expenses are reset, THE Bill_Provider SHALL NOT modify the active Income_Entry list, Total_Income, or any income History batch in any way.

---

### Requirement 6: Reset Income

**User Story:** As a user, I want to reset my income entries to zero and have the old data sent to history, so that I can start a fresh income tracking period without losing past records.

#### Acceptance Criteria

1. THE Bill_Tracker SHALL display a "Reset Income" button in the income section; WHEN the active Income_Entry list is empty, THE button SHALL be disabled (non-interactive) and visually dimmed.
2. WHEN the user taps the enabled "Reset Income" button, THE Bill_Tracker SHALL present a modal confirmation dialog containing a descriptive warning message (e.g., "This will move all income entries to history") and two explicit actions: "Confirm" and "Cancel".
3. WHEN the user taps "Confirm" in the reset dialog, THE Bill_Provider SHALL create a History batch record containing a snapshot of all current active Income_Entry items and the UTC timestamp of the moment the user tapped "Confirm".
4. WHEN the user taps "Confirm" in the reset dialog, THE Bill_Provider SHALL persist the History batch to the "bill_history" Hive_Box AND clear the active Income_Entry list from the "bill_entries" Hive_Box in a single logical operation; IF either write fails, THEN THE Bill_Provider SHALL preserve the prior state unchanged and display an error message in the UI.
5. WHEN the reset completes successfully, THE Bill_Tracker SHALL display Total_Income as "₹0.00" and render the income empty-state placeholder within 1 second.
6. WHEN the user taps "Cancel" in the reset dialog, THE Bill_Provider SHALL leave the active Income_Entry list, Total_Income, and all History data unchanged.
7. WHEN income is reset, THE Bill_Provider SHALL NOT modify the active Expense_Entry list, Total_Expense, or any expense History batch in any way.

---

### Requirement 7: History and Auto-Purge

**User Story:** As a user, I want to view past entries that were sent to history after a reset, and have entries older than 20 days automatically removed, so that history stays relevant and storage stays lean.

#### Acceptance Criteria

1. THE Bill_Tracker SHALL provide a History view that lists all previously reset batches (both expense and income) ordered from most recent reset date to oldest, each showing the batch type (expense or income), the number of entries, total amount, and formatted reset date.
2. WHEN a reset batch is added to History, THE Bill_Provider SHALL record the UTC timestamp of the reset as the batch's reset timestamp.
3. WHEN the app starts, THE Bill_Provider SHALL evaluate each History batch independently and remove any batch whose reset timestamp, when compared using date-only (ignoring time-of-day), is more than 20 calendar days before the current device date.
4. WHEN the app starts and the auto-purge check runs, THE Bill_Provider SHALL NOT evaluate or remove any active (non-reset) Expense_Entry or Income_Entry as part of that check.
5. WHEN all entries in a reset batch have been purged during the auto-purge check, THE Bill_Tracker SHALL remove that batch from the History view and SHALL NOT display an empty batch container.
6. IF a Hive write error occurs during the auto-purge deletion of a batch, THEN THE Bill_Provider SHALL preserve that batch in History unchanged, log the error, and continue evaluating the remaining batches.
7. WHEN the History view is empty (no batches remain), THE Bill_Tracker SHALL render a non-empty placeholder message (e.g., "No history yet") and SHALL NOT render an empty list container.

---

### Requirement 8: Persistent Storage

**User Story:** As a user, I want my expense and income data to persist across app restarts and device reboots, so that I never lose financial records unintentionally.

#### Acceptance Criteria

1. THE Bill_Provider SHALL store all active Expense_Entry and Income_Entry objects in a dedicated Hive_Box named "bill_entries" using registered TypeAdapters.
2. THE Bill_Provider SHALL store all History batch objects in a dedicated Hive_Box named "bill_history" using registered TypeAdapters.
3. WHEN the app is closed and reopened, THE Bill_Provider SHALL read "bill_entries" and "bill_history" Hive_Boxes on initialization and restore the active entry lists and history batches to the same state as when the app was last closed.
4. THE Bill_Provider SHALL NOT use Flutter's ephemeral widget cache, `SharedPreferences`, or any in-memory-only mechanism as the sole persistence layer for entry or history data.
5. FOR ALL Expense_Entry and Income_Entry objects written to a Hive_Box and subsequently read back, THE deserialized object SHALL have equal values for every field (id, type, amount, name, dateTime) as the original (round-trip property).
6. WHEN the "bill_entries" or "bill_history" Hive_Box fails to open on startup, THE Bill_Provider SHALL surface an error message to the user and SHALL fall back to an empty in-memory state rather than crashing.

---

### Requirement 9: State Management

**User Story:** As a developer, I want all Bill_Tracker state managed through Riverpod providers, so that the app maintains consistent, performant, and testable state throughout.

#### Acceptance Criteria

1. THE Bill_Provider SHALL be implemented as a Riverpod `AsyncNotifier` or `StateNotifier` that exposes the following as observable state: the active expense list (`List<Expense_Entry>`), the active income list (`List<Income_Entry>`), Total_Expense (`double`), and Total_Income (`double`).
2. WHEN an Expense_Entry or Income_Entry is added, reset, or purged, THE Bill_Provider SHALL emit a new, immutable state object containing the updated lists and recalculated totals, causing all subscribed widgets to rebuild.
3. THE Bill_Tracker widgets SHALL NOT store persistent entry data in local `StatefulWidget` fields or `State` objects; ALL persistent state SHALL be derived exclusively from THE Bill_Provider.
4. THE Bill_Tracker provider(s) and THE Splitter provider(s) SHALL be declared as separate, independent Riverpod providers; WHEN a Bill_Tracker-specific state mutation occurs, IT SHALL NOT cause any Splitter widget that is not watching a Bill_Tracker provider to rebuild.
5. WHEN THE Bill_Provider is first read (provider initialization), IT SHALL trigger an asynchronous load of data from the Hive_Boxes before exposing state to the UI, and WHILE the load is in progress THE Bill_Tracker SHALL display a loading indicator.

---

### Requirement 10: UI Design and Visual Consistency

**User Story:** As a user, I want the Bill section to feel modern, minimal, and visually cohesive with the rest of the Ploy app, so that the overall experience feels polished and intentional.

#### Acceptance Criteria

1. THE Bill_Tracker SHALL use exclusively the AppTheme color constants: `primaryBg` (0xFF312E6B) for backgrounds, `surface` (0xFF3D3A7A) for cards and containers, `accentWarm` (0xFFF5C98A) for income highlights and primary actions, `accentButton` (0xFF5B55C0) for secondary actions, `textPrimary` (white) for body text, and `textSecondary` (0xFFB8B4E8) for labels and captions.
2. THE Bill_Tracker SHALL use Plus Jakarta Sans via `GoogleFonts.plusJakartaSansTextTheme` for all text widgets, with no fallback to the system default font for Bill_Tracker-specific text.
3. ALL card and container widgets in THE Bill_Tracker SHALL use a `BorderRadius.circular(20)` (AppTheme.cardRadius) for their shape; no card SHALL use a different radius.
4. THE Bill_Tracker SHALL use a distinct accent color or icon to differentiate Expense_Entry items from Income_Entry items: expense items SHALL use a red-toned color (e.g., Colors.redAccent) or a downward-arrow icon, and income items SHALL use `accentWarm` or an upward-arrow icon.
5. THE Entry_Form SHALL be presented as a `showModalBottomSheet` with `isScrollControlled: true` and a slide-up animation; it SHALL NOT be presented as a full-screen route or an inline form.
6. WHEN the combined list of expense and income entries exceeds the visible viewport height, THE Bill_Tracker SHALL render the content inside a `ListView` or `SingleChildScrollView` that allows smooth vertical scrolling without overflow errors.
7. WHEN a new entry is appended to the active list, THE Bill_Tracker SHALL animate the new item into view using a fade-in or slide-fade transition consistent with the existing `FadeSlide` widget pattern used in the app.
