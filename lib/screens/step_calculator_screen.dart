import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_calc/providers/calculation_provider.dart';

class StepCalculatorScreen extends StatefulWidget {
  const StepCalculatorScreen({super.key});

  @override
  State<StepCalculatorScreen> createState() => _StepCalculatorScreenState();
}

class _StepCalculatorScreenState extends State<StepCalculatorScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _solution = '';
  bool _isProcessing = false;

  Future<void> _getSolution() async {
    if (_inputController.text.isEmpty) return;

    setState(() => _isProcessing = true);
    try {
      final solution = await context.read<CalculationProvider>()
          .getStepByStepSolution(_inputController.text);
      setState(() => _solution = solution);
    } catch (e) {
      setState(() => _solution = 'Error generating solution: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step-by-Step Solution'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: _solution.isNotEmpty ? () {
              // TODO: Implement graph view
            } : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: 'Enter mathematical expression',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _inputController.clear();
                    setState(() => _solution = '');
                  },
                ),
              ),
              onSubmitted: (_) => _getSolution(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _getSolution,
              icon: _isProcessing 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.calculate),
              label: Text(_isProcessing ? 'Calculating...' : 'Solve Step by Step'),
            ),
            const SizedBox(height: 24),
            if (_solution.isNotEmpty)
              Expanded(
                child: Card(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _solution,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}