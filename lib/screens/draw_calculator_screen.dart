import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:provider/provider.dart';
import 'package:smart_calc/providers/calculation_provider.dart';

class DrawCalculatorScreen extends StatefulWidget {
  const DrawCalculatorScreen({super.key});

  @override
  State<DrawCalculatorScreen> createState() => _DrawCalculatorScreenState();
}

class _DrawCalculatorScreenState extends State<DrawCalculatorScreen> {
  final DrawingController _drawingController = DrawingController();
  String _result = '';
  bool _isProcessing = false;

  Future<void> _processDrawing() async {
    setState(() => _isProcessing = true);

    try {
      // Get the drawing as a description
      // For now, we'll send a basic description. In a real app,
      // you'd process the image to text first
      final description = "User drawn mathematical expression";
      
      final result = await context.read<CalculationProvider>()
          .processDrawing(description);
      
      setState(() => _result = result);
    } catch (e) {
      setState(() => _result = 'Error processing drawing: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _clearDrawing() {
    _drawingController.clear();
    setState(() => _result = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw to Calculate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: () {
              // TODO: Implement graph view
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: DrawingBoard(
              controller: _drawingController,
              background: Container(
                color: Theme.of(context).colorScheme.surface,
              ),
              showDefaultActions: false,
              showDefaultTools: false,
            ),
          ),
          if (_result.isNotEmpty)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surface,
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearDrawing,
              tooltip: 'Clear',
            ),
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: _drawingController.undo,
              tooltip: 'Undo',
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: _drawingController.redo,
              tooltip: 'Redo',
            ),
            ElevatedButton.icon(
              icon: _isProcessing 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
              label: Text(_isProcessing ? 'Processing...' : 'Calculate'),
              onPressed: _isProcessing ? null : _processDrawing,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }
}