import 'package:flutter/material.dart';

import '../../domain/entities/split_expense.dart';

class SplitExpenseScreen extends StatefulWidget {
  const SplitExpenseScreen({super.key});

  @override
  State<SplitExpenseScreen> createState() => _SplitExpenseScreenState();
}

class _SplitExpenseScreenState extends State<SplitExpenseScreen> {
  final List<SplitExpense> _splits = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Split Bills')),
      body: _splits.isEmpty ? _buildEmpty() : _buildSplitList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSplitDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No split bills', style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 8),
          Text('Tap + to split a bill with friends', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSplitList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _splits.length,
      itemBuilder: (context, index) {
        final split = _splits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: split.isFullySettled
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.orange.withValues(alpha: 0.2),
              child: Icon(
                split.isFullySettled ? Icons.check : Icons.receipt,
                color: split.isFullySettled ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(split.description),
            subtitle: Text(
              '\u20B9${split.totalAmount.toStringAsFixed(2)} • Paid by ${split.paidBy}',
            ),
            trailing: split.isFullySettled
                ? const Chip(label: Text('Settled', style: TextStyle(fontSize: 11)))
                : Text(
                    '\u20B9${split.unsettledAmount.toStringAsFixed(0)} pending',
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
            children: [
              ...split.participants.asMap().entries.map((entry) {
                final i = entry.key;
                final participant = entry.value;
                return ListTile(
                  dense: true,
                  leading: Icon(
                    participant.isPaid ? Icons.check_circle : Icons.circle_outlined,
                    color: participant.isPaid ? Colors.green : Colors.grey,
                  ),
                  title: Text(participant.name),
                  trailing: Text('\u20B9${participant.share.toStringAsFixed(2)}'),
                  onTap: () {
                    setState(() {
                      final updatedParticipants = List<Participant>.from(split.participants);
                      updatedParticipants[i] = participant.copyWith(isPaid: !participant.isPaid);
                      _splits[index] = SplitExpense(
                        id: split.id,
                        description: split.description,
                        totalAmount: split.totalAmount,
                        paidBy: split.paidBy,
                        date: split.date,
                        participants: updatedParticipants,
                      );
                    });
                  },
                );
              }),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton.icon(
                  onPressed: () => setState(() => _splits.removeAt(index)),
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  label: const Text('Remove', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateSplitDialog() {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    final paidByController = TextEditingController();
    final participantNames = <TextEditingController>[
      TextEditingController(),
      TextEditingController(),
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Split a Bill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description', hintText: 'e.g. Dinner at restaurant'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Total Amount', prefixText: '\u20B9 '),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: paidByController,
                  decoration: const InputDecoration(labelText: 'Paid By', hintText: 'Your name'),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Participants:', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...participantNames.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: entry.value,
                            decoration: InputDecoration(
                              labelText: 'Person ${entry.key + 1}',
                              isDense: true,
                            ),
                          ),
                        ),
                        if (participantNames.length > 2)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 20),
                            onPressed: () {
                              setDialogState(() => participantNames.removeAt(entry.key));
                            },
                          ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () {
                    setDialogState(() => participantNames.add(TextEditingController()));
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Person'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                final names = participantNames
                    .map((c) => c.text.trim())
                    .where((n) => n.isNotEmpty)
                    .toList();

                if (descController.text.isNotEmpty &&
                    amount != null &&
                    amount > 0 &&
                    paidByController.text.isNotEmpty &&
                    names.length >= 2) {
                  final sharePerPerson = amount / names.length;
                  setState(() {
                    _splits.add(SplitExpense(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      description: descController.text,
                      totalAmount: amount,
                      paidBy: paidByController.text.trim(),
                      date: DateTime.now(),
                      participants: names
                          .map((n) => Participant(name: n, share: sharePerPerson))
                          .toList(),
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Split'),
            ),
          ],
        ),
      ),
    );
  }
}
