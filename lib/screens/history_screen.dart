import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/split_session.dart';
import '../widgets/avatar_bubble.dart';
import '../theme/app_theme.dart';

enum SessionFilter { all, active, settled }

class HistoryScreen extends ConsumerStatefulWidget {
  final String? sessionId;

  const HistoryScreen({super.key, this.sessionId});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  SessionFilter _currentFilter = SessionFilter.all;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<SplitSession>>(
      valueListenable: Hive.box<SplitSession>('sessions').listenable(),
      builder: (context, box, _) {
        final allSessions = box.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final filteredSessions = _filterSessions(allSessions);
        final stats = _calculateStats(allSessions);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Split History'),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'clear_settled') {
                    _clearSettledSessions();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear_settled',
                    child: Text('Clear Settled Sessions'),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Summary Stats
              _buildSummaryStats(stats),

              // Filter Tabs
              _buildFilterTabs(),

              // Sessions List
              Expanded(
                child: filteredSessions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredSessions.length,
                        itemBuilder: (context, index) {
                          return _SessionCard(
                            session: filteredSessions[index],
                            onTap: () =>
                                _showSessionDetail(filteredSessions[index]),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<SplitSession> _filterSessions(List<SplitSession> sessions) {
    switch (_currentFilter) {
      case SessionFilter.active:
        return sessions.where((s) => !s.isSettled).toList();
      case SessionFilter.settled:
        return sessions.where((s) => s.isSettled).toList();
      case SessionFilter.all:
        return sessions;
    }
  }

  Map<String, dynamic> _calculateStats(List<SplitSession> sessions) {
    if (sessions.isEmpty) {
      return {
        'totalSessions': 0,
        'totalAmount': 0.0,
        'mostFrequentCoSplitter': 'None',
      };
    }

    final totalAmount = sessions.fold(0.0, (sum, s) => sum + s.totalAmount);

    // Calculate most frequent co-splitter
    final participantCounts = <String, int>{};
    for (final session in sessions) {
      for (final participant in session.participants) {
        participantCounts[participant.name] =
            (participantCounts[participant.name] ?? 0) + 1;
      }
    }

    final mostFrequent = participantCounts.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    return {
      'totalSessions': sessions.length,
      'totalAmount': totalAmount,
      'mostFrequentCoSplitter': mostFrequent.key,
    };
  }

  Widget _buildSummaryStats(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Sessions', value: '${stats['totalSessions']}'),
          _StatItem(
            label: 'Total Split',
            value: '₹${stats['totalAmount'].toStringAsFixed(0)}',
          ),
          _StatItem(
            label: 'Top Partner',
            value: stats['mostFrequentCoSplitter'],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<SessionFilter>(
              segments: const [
                ButtonSegment(value: SessionFilter.all, label: Text('All')),
                ButtonSegment(
                  value: SessionFilter.active,
                  label: Text('Active'),
                ),
                ButtonSegment(
                  value: SessionFilter.settled,
                  label: Text('Settled'),
                ),
              ],
              selected: {_currentFilter},
              onSelectionChanged: (Set<SessionFilter> selection) {
                setState(() {
                  _currentFilter = selection.first;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    switch (_currentFilter) {
      case SessionFilter.active:
        message = 'No active sessions';
        break;
      case SessionFilter.settled:
        message = 'No settled sessions';
        break;
      case SessionFilter.all:
        message = 'No saved sessions yet';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showSessionDetail(SplitSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SessionDetailSheet(session: session),
    );
  }

  void _clearSettledSessions() {
    final box = Hive.box<SplitSession>('sessions');
    final settledSessions = box.values.where((s) => s.isSettled).toList();

    if (settledSessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No settled sessions to clear')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Settled Sessions'),
        content: Text('Remove ${settledSessions.length} settled sessions?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              for (final session in settledSessions) {
                box.delete(session.id);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cleared ${settledSessions.length} sessions'),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.accentWarm,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SplitSession session;
  final VoidCallback onTap;

  const _SessionCard({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(session.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(isSettled: session.isSettled),
                ],
              ),

              const SizedBox(height: 12),

              // Participants row
              Row(
                children: [
                  // Stacked avatars
                  SizedBox(height: 32, child: _buildStackedAvatars()),
                  const SizedBox(width: 12),
                  Text(
                    '${session.participants.length} people',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Amount
              Text(
                '₹${session.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.accentWarm,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStackedAvatars() {
    const maxVisible = 3;
    final visibleParticipants = session.participants.take(maxVisible).toList();
    final remainingCount = session.participants.length - maxVisible;

    return Stack(
      children: [
        ...visibleParticipants.asMap().entries.map((entry) {
          final index = entry.key;
          final participant = entry.value;
          return Positioned(
            left: index * 20.0,
            child: AvatarBubble(
              name: participant.name,
              avatarEmoji: participant.avatarEmoji,
              avatarSize: AvatarSize.small,
            ),
          );
        }),
        if (remainingCount > 0)
          Positioned(
            left: maxVisible * 20.0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.textSecondary, width: 1),
              ),
              child: Center(
                child: Text(
                  '+$remainingCount',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _StatusChip extends StatelessWidget {
  final bool isSettled;

  const _StatusChip({required this.isSettled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSettled
            ? Colors.green.withValues(alpha: 0.2)
            : Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.chipRadius),
      ),
      child: Text(
        isSettled ? 'Settled' : 'Active',
        style: TextStyle(
          color: isSettled ? Colors.green : Colors.amber,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SessionDetailSheet extends ConsumerStatefulWidget {
  final SplitSession session;

  const _SessionDetailSheet({required this.session});

  @override
  ConsumerState<_SessionDetailSheet> createState() =>
      _SessionDetailSheetState();
}

class _SessionDetailSheetState extends ConsumerState<_SessionDetailSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.primaryBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.session.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(widget.session.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _shareSession(),
                      icon: const Icon(Icons.share),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Expenses section
                    _buildExpensesSection(),

                    const SizedBox(height: 24),

                    // Settlements section
                    _buildSettlementsSection(),

                    const SizedBox(height: 24),

                    // Actions
                    _buildActions(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpensesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expenses', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...widget.session.expenses.map((expense) {
          final payer = widget.session.participants.firstWhere(
            (p) => p.id == expense.paidById,
          );
          final splitAmong = widget.session.participants
              .where((p) => expense.splitAmongIds.contains(p.id))
              .toList();

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          expense.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '₹${expense.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.accentWarm,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paid by ${payer.name}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Split among: ${splitAmong.map((p) => p.name).join(', ')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSettlementsSection() {
    final settlements = _calculateSettlements();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Settlements', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (settlements.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('All settled up! 🎉'),
            ),
          )
        else
          ...settlements.map((settlement) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    AvatarBubble(
                      name: settlement['from'],
                      avatarSize: AvatarSize.small,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${settlement['from']} owes ${settlement['to']}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Text(
                      '₹${settlement['amount'].toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.accentWarm,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Mark as Settled'),
          subtitle: const Text('Toggle settlement status'),
          value: widget.session.isSettled,
          onChanged: (value) => _toggleSettled(value),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _shareSession,
            icon: const Icon(Icons.share),
            label: const Text('Share Settlement'),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _calculateSettlements() {
    // Simple settlement calculation - in a real app this would be more sophisticated
    final balances = <String, double>{};

    // Initialize balances
    for (final participant in widget.session.participants) {
      balances[participant.name] = 0.0;
    }

    // Calculate what each person owes/is owed
    for (final expense in widget.session.expenses) {
      final payer = widget.session.participants.firstWhere(
        (p) => p.id == expense.paidById,
      );
      final splitAmount = expense.amount / expense.splitAmongIds.length;

      // Payer gets credited
      balances[payer.name] = (balances[payer.name] ?? 0) + expense.amount;

      // Each person in split gets debited
      for (final participantId in expense.splitAmongIds) {
        final participant = widget.session.participants.firstWhere(
          (p) => p.id == participantId,
        );
        balances[participant.name] =
            (balances[participant.name] ?? 0) - splitAmount;
      }
    }

    // Generate settlements
    final settlements = <Map<String, dynamic>>[];
    final debtors = balances.entries.where((e) => e.value < -0.01).toList();
    final creditors = balances.entries.where((e) => e.value > 0.01).toList();

    for (final debtor in debtors) {
      for (final creditor in creditors) {
        if (debtor.value.abs() > 0.01 && creditor.value > 0.01) {
          final amount = [
            debtor.value.abs(),
            creditor.value,
          ].reduce((a, b) => a < b ? a : b);
          settlements.add({
            'from': debtor.key,
            'to': creditor.key,
            'amount': amount,
          });

          // Update balances
          balances[debtor.key] = (balances[debtor.key] ?? 0) + amount;
          balances[creditor.key] = (balances[creditor.key] ?? 0) - amount;
        }
      }
    }

    return settlements;
  }

  void _toggleSettled(bool value) {
    final box = Hive.box<SplitSession>('sessions');
    final updatedSession = SplitSession(
      id: widget.session.id,
      title: widget.session.title,
      participants: widget.session.participants,
      expenses: widget.session.expenses,
      createdAt: widget.session.createdAt,
      isSettled: value,
    );

    box.put(widget.session.id, updatedSession);
    setState(() {
      // Trigger rebuild
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Session marked as settled' : 'Session marked as active',
        ),
      ),
    );
  }

  void _shareSession() {
    final settlements = _calculateSettlements();
    final buffer = StringBuffer();

    buffer.writeln('💰 ${widget.session.title}');
    buffer.writeln('📅 ${_formatDate(widget.session.createdAt)}');
    buffer.writeln(
      '💵 Total: ₹${widget.session.totalAmount.toStringAsFixed(2)}',
    );
    buffer.writeln();

    if (settlements.isEmpty) {
      buffer.writeln('🎉 All settled up!');
    } else {
      buffer.writeln('💸 Settlements:');
      for (final settlement in settlements) {
        buffer.writeln(
          '${settlement['from']} → ${settlement['to']}: ₹${settlement['amount'].toStringAsFixed(2)}',
        );
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settlement details copied to clipboard')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
