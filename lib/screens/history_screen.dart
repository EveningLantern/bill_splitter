import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split History'),
      ),
      body: history.isEmpty
          ? const Center(child: Text('No saved sessions yet.'))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final session = history[index];
                return Dismissible(
                  key: Key(session.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    ref.read(historyProvider.notifier).deleteSession(session.id);
                  },
                  child: ListTile(
                    title: Text(session.title),
                    subtitle: Text('${session.participants.length} people • ${session.createdAt.day}/${session.createdAt.month}/${session.createdAt.year}'),
                    trailing: Text(
                      '₹${session.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // TODO: Details view
                    },
                  ),
                );
              },
            ),
    );
  }
}
