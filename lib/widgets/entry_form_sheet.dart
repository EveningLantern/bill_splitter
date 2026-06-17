import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bill_entry.dart';
import '../providers/bill_provider.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EntryFormMode — discriminates expense vs income form
// ─────────────────────────────────────────────────────────────────────────────

enum EntryFormMode { expense, income }

// ─────────────────────────────────────────────────────────────────────────────
// EntryFormSheet — modal bottom sheet for adding an expense or income entry
// ─────────────────────────────────────────────────────────────────────────────

/// Modal bottom sheet that lets the user add a new [BillEntry].
///
/// Launch via [EntryFormSheet.show] rather than constructing directly.
/// Requirements: 3.1–3.11, 4.1–4.11, 10.5
class EntryFormSheet extends ConsumerStatefulWidget {
  final EntryFormMode mode;

  const EntryFormSheet({required this.mode, super.key});

  /// Convenience launcher — wraps [showModalBottomSheet] with the correct
  /// settings (isScrollControlled, transparent background, slide-up animation).
  static Future<void> show(BuildContext context, EntryFormMode mode) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => EntryFormSheet(mode: mode),
      );

  @override
  ConsumerState<EntryFormSheet> createState() => _EntryFormSheetState();
}

class _EntryFormSheetState extends ConsumerState<EntryFormSheet> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();

  /// Pre-populated with DateTime.now() truncated to the minute
  /// (seconds and microseconds zeroed out). Requirements: 3.5, 4.5.
  late DateTime _selectedDateTime;

  String? _amountError;
  String? _nameError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  /// Validates both fields. Returns true if both are valid.
  /// Sets [_amountError] and [_nameError] with inline error strings.
  bool _validate() {
    final rawAmount = _amountController.text.trim();
    final parsed = double.tryParse(rawAmount);
    final nameLen = _nameController.text.trim().length;

    String? amtErr;
    String? nameErr;

    if (parsed == null || parsed < 0.01 || parsed > 999999999.99) {
      amtErr = 'Enter an amount between 0.01 and 999,999,999.99';
    }

    if (nameLen < 1 || nameLen > 100) {
      nameErr = 'Name must be 1–100 characters';
    }

    setState(() {
      _amountError = amtErr;
      _nameError = nameErr;
    });

    return amtErr == null && nameErr == null;
  }

  // ── Submission ─────────────────────────────────────────────────────────────

  /// Validates, creates the entry, calls the provider, dismisses on success.
  /// Requirements: 3.7–3.11, 4.7–4.11.
  Future<void> _submit() async {
    // Clear previous errors and validate.
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final amount = double.parse(_amountController.text.trim());
      final name = _nameController.text.trim();

      final entry = BillEntry(
        type: widget.mode == EntryFormMode.expense
            ? BillEntryType.expense
            : BillEntryType.income,
        amount: amount,
        name: name,
        dateTime: _selectedDateTime,
      );

      await ref.read(billProvider.notifier).addEntry(entry);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save entry. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.mode == EntryFormMode.expense;
    final title = isExpense ? 'Add Expense' : 'Add Income';
    final nameLabel = isExpense ? 'Product / Item name' : 'Income source';

    return Padding(
      // Push the sheet up when the keyboard is visible. Requirement 10.5.
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.cardRadius),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Drag handle ─────────────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Title ────────────────────────────────────────────────────
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),

              // ── Amount field ─────────────────────────────────────────────
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  errorText: _amountError,
                ),
                onChanged: (_) {
                  if (_amountError != null) {
                    setState(() => _amountError = null);
                  }
                },
              ),
              const SizedBox(height: 16),

              // ── Name / Source field ──────────────────────────────────────
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: nameLabel,
                  errorText: _nameError,
                ),
                onChanged: (_) {
                  if (_nameError != null) {
                    setState(() => _nameError = null);
                  }
                },
              ),
              const SizedBox(height: 16),

              // ── Date-time picker row ─────────────────────────────────────
              _DateTimePicker(
                value: _selectedDateTime,
                onChanged: (dt) => setState(() => _selectedDateTime = dt),
              ),
              const SizedBox(height: 24),

              // ── Save button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryBg,
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DateTimePicker — tappable row showing selected date & time
// ─────────────────────────────────────────────────────────────────────────────

/// Shows the currently selected date and time, and opens
/// [showDatePicker] → [showTimePicker] in sequence when tapped.
/// Requirements: 3.5, 3.6, 4.5, 4.6.
class _DateTimePicker extends StatelessWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const _DateTimePicker({required this.value, required this.onChanged});

  Future<void> _pick(BuildContext context) async {
    // Step 1: pick a date
    final date = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return; // user cancelled

    // Guard against widget disposal between async gaps
    if (!context.mounted) return;

    // Step 2: pick a time
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: value.hour, minute: value.minute),
    );

    if (time == null) return; // user cancelled

    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    onChanged(combined);
  }

  @override
  Widget build(BuildContext context) {
    // Format: "15 Jun 2025  •  14:30"
    final day = value.day.toString().padLeft(2, '0');
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthNames[value.month - 1];
    final year = value.year;
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final formatted = '$day $month $year  •  $hour:$minute';

    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.primaryBg,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formatted,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
