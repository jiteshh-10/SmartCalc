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
  Color _selectedColor = Colors.black; // Default color for drawing

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

  // Function to set the selected color
  void _changeColor(Color color) {
    setState(() {
      _selectedColor = color;
      _drawingController.updateSettings(color: _selectedColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCalc - Draw to Calculate'),
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
          // Drawing area
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
          // Display result if any
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
          // Color palette
          Container(
            height: 50,
            color: Theme.of(context).colorScheme.background,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildColorOption(Colors.black),
                _buildColorOption(Colors.red),
                _buildColorOption(Colors.blue),
                _buildColorOption(Colors.green),
                _buildColorOption(Colors.orange),
                _buildColorOption(Colors.purple),
                _buildColorOption(Colors.brown),
              ],
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

  // Widget to build color selection option
  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () => _changeColor(color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor == color ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        width: 36,
        height: 36,
      ),
    );
  }

  @override
  void dispose() {
    _drawingController.dispose();
    super.dispose();
  }
}

extension on DrawingController {
  void updateSettings({required Color color}) {}
}
