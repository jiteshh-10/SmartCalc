import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:smart_calc/models/calculation_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<CalculationHistory> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('calculation_history') ?? [];
    setState(() {
      _history = historyJson
          .map((item) => CalculationHistory.fromMap(json.decode(item)))
          .toList();
    });
  }

  Future<void> _deleteHistoryItem(String id) async {
    setState(() {
      _history.removeWhere((item) => item.id == id);
    });
    await _saveHistory();
  }

  Future<void> _clearHistory() async {
    setState(() {
      _history.clear();
    });
    await _saveHistory();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson =
        _history.map((item) => json.encode(item.toMap())).toList();
    await prefs.setStringList('calculation_history', historyJson);
  }

  @override
  Widget build(BuildContext context) {
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
                  content:
                      const Text('Are you sure you want to clear all history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _clearHistory();
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
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          return Dismissible(
            key: Key(item.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) => _deleteHistoryItem(item.id),
            child: ListTile(
              title: Text(item.expression),
              subtitle: Text(item.result),
              trailing: Text(
                '${item.timestamp.hour}:${item.timestamp.minute}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () {
                // Navigate to specific calculator based on type
                // Implementation depends on your navigation setup
              },
            ),
          );
        },
      ),
    );
  }
}
