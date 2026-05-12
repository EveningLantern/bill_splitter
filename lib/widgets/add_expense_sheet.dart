import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../models/person.dart';
import '../theme/app_theme.dart';
import '../providers/session_provider.dart';

/// Bottom sheet for adding a single expense.
class AddExpenseSheet extends ConsumerStatefulWidget {
  final List<Person> participants;
  const AddExpenseSheet({super.key, required this.participants});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _paidById;
  late Set<String> _splitAmongIds;

  @override
  void initState() {
    super.initState();
    _paidById = widget.participants.isNotEmpty
        ? widget.participants.first.id
        : null;
    _splitAmongIds = widget.participants.map((p) => p.id).toSet();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (title.isEmpty ||
        amount == null ||
        amount <= 0 ||
        _paidById == null ||
        _splitAmongIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly.')),
      );
      return;
    }
    ref
        .read(splitSessionNotifierProvider.notifier)
        .addExpense(
          Expense(
            title: title,
            amount: amount,
            paidById: _paidById!,
            splitAmongIds: _splitAmongIds.toList(),
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 8,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            Text('Add Expense', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // Title
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'What was it? (e.g. Dinner)',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),

            // Amount
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 20),

            // Paid by
            Text(
              'Paid by',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: widget.participants.map((p) {
                  final selected = _paidById == p.id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p.name),
                      selected: selected,
                      selectedColor: AppTheme.accentWarm,
                      labelStyle: TextStyle(
                        color: selected
                            ? AppTheme.primaryBg
                            : AppTheme.textPrimary,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _paidById = p.id),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Split among
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Split among',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(
                    () => _splitAmongIds = widget.participants
                        .map((p) => p.id)
                        .toSet(),
                  ),
                  child: const Text('Select all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.participants.map((p) {
                final selected = _splitAmongIds.contains(p.id);
                return FilterChip(
                  label: Text(p.name),
                  selected: selected,
                  selectedColor: AppTheme.accentButton.withValues(alpha: 0.5),
                  onSelected: (val) => setState(() {
                    if (val) {
                      _splitAmongIds.add(p.id);
                    } else {
                      _splitAmongIds.remove(p.id);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Confirm
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Add Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
