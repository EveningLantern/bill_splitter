import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/active_session_provider.dart';
import '../theme/app_theme.dart';
import 'split_steps/step1_setup.dart';
import 'split_steps/step2_expenses.dart';
import 'split_steps/step3_review.dart';

class SplitNowScreen extends ConsumerStatefulWidget {
  const SplitNowScreen({super.key});

  @override
  ConsumerState<SplitNowScreen> createState() => _SplitNowScreenState();
}

class _SplitNowScreenState extends ConsumerState<SplitNowScreen> {
  int _step = 0;
  final PageController _pageCtrl = PageController();

  static const _titles = ['Session Setup', 'Add Expenses', 'Review & Settle'];
  static const _stepLabels = ['Setup', 'Expenses', 'Review'];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageCtrl.animateToPage(step, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
  }


  String? _blockReason(int step) {
    final session = ref.read(activeSessionProvider);
    if (step == 0) {
      if (session.title.isEmpty) return 'Please enter a session title.';
      if (session.participants.length < 2) return 'Add at least 2 participants.';
    }
    if (step == 1 && session.expenses.isEmpty) return 'Add at least one expense.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBg,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.surface,
                title: const Text('Discard session?'),
                content: const Text('All progress will be lost.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep editing')),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ref.read(activeSessionProvider.notifier).reset();
                      context.go('/');
                    },
                    child: const Text('Discard', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text(_titles[_step]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _StepIndicator(currentStep: _step, labels: _stepLabels, onTap: (i) {
            if (i < _step) _goTo(i);
          }),
        ),
      ),

      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: const [Step1Setup(), Step2Expenses(), Step3Review()],
      ),

      bottomNavigationBar: _step < 2
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _goTo(_step - 1),
                          child: const Text('← Back'),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () {
                          final reason = _blockReason(_step);
                          if (reason != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(reason), behavior: SnackBarBehavior.floating),
                            );
                            return;
                          }
                          _goTo(_step + 1);
                        },
                        child: const Text('Next →'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

// ── Step indicator bar ────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> labels;
  final ValueChanged<int> onTap;
  const _StepIndicator({required this.currentStep, required this.labels, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stepIdx = i ~/ 2;
            final active = stepIdx < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                color: active ? AppTheme.accentWarm : AppTheme.textSecondary.withValues(alpha: 0.3),
              ),
            );
          }
          final idx = i ~/ 2;
          final done = idx < currentStep;
          final active = idx == currentStep;
          return GestureDetector(
            onTap: () => onTap(idx),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: active ? 32 : 26,
                  height: active ? 32 : 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? AppTheme.accentWarm
                        : done
                            ? Colors.greenAccent.shade700
                            : AppTheme.surface,
                    border: Border.all(
                      color: active ? AppTheme.accentWarm : done ? Colors.greenAccent : AppTheme.textSecondary,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: active ? AppTheme.primaryBg : AppTheme.textSecondary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  labels[idx],
                  style: TextStyle(
                    fontSize: 10,
                    color: active ? AppTheme.accentWarm : AppTheme.textSecondary,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
