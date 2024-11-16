import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_calc/models/calculation_history.dart';
import 'package:smart_calc/providers/calculation_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculationProvider>();
    final history = provider.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Are you sure you want to clear all history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        provider.clearHistory();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return Dismissible(
            key: Key(item.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => provider.deleteHistoryItem(item.id),
            child: ListTile(
              title: Text(item.expression),
              subtitle: Text(item.result),
              trailing: Text(
                '${item.timestamp.hour}:${item.timestamp.minute}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () {
                // You can navigate to a specific screen based on `item.type`
                // if needed
              },
            ),
          );
        },
      ),
    );
  }
}
