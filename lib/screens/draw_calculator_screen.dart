import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import 'package:smart_calc/providers/calculation_provider.dart';

class DrawCalculatorScreen extends StatefulWidget {
  const DrawCalculatorScreen({Key? key}) : super(key: key);

  @override
  _DrawCalculatorScreenState createState() => _DrawCalculatorScreenState();
}

class _DrawCalculatorScreenState extends State<DrawCalculatorScreen> {
  List<DrawnLine> _lines = [];
  List<Offset?> _currentLine = [];
  String _result = '';
  bool _isProcessing = false;
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;
  bool _isErasing = false;

  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void _updateDrawingSettings({Color? color, double? thickness, bool? isErasing}) {
    setState(() {
      if (color != null) _selectedColor = color;
      if (thickness != null) _strokeWidth = thickness;
      if (isErasing != null) _isErasing = isErasing;
    });
  }

  void _clearDrawing() {
    setState(() {
      _lines.clear();
      _result = '';
    });
  }

  Future<void> _processDrawing() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final imageFile = await _saveDrawingAsImage();
      if (imageFile == null) throw Exception('Failed to capture drawing');

      final extractedText = await _extractTextFromImage(imageFile);
      if (extractedText.isEmpty) throw Exception('No text recognized');

      final result = await _processWithGemini(extractedText);

      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<String> _processWithGemini(String extractedText) async {
    try {
      final prompt = '''
      The following is a handwritten mathematical expression extracted via OCR:
      $extractedText

      Please:
      1. Interpret the mathematical expression.
      2. Calculate the result.
      3. Return only the numerical result.

      If there are any errors or the expression is invalid, explain the issue.
      ''';

      final result = await context.read<CalculationProvider>().processDrawing(prompt);

      return result;
    } catch (e) {
      throw Exception('Gemini API error: ${e.toString()}');
    }
  }

  Future<File?> _saveDrawingAsImage() async {
    try {
      final boundary = _repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png';

      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(buffer);

      return imageFile;
    } catch (e) {
      return null;
    }
  }

  Future<String> _extractTextFromImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      final extractedText = recognizedText.blocks
          .map((block) => block.text)
          .join(' ')
          .replaceAll('x', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-')
          .trim();

      return extractedText;
    } finally {
      textRecognizer.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw to Calculate'),
        actions: [
          if (_result.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: () {
                setState(() {
                  _result = '';
                  _clearDrawing();
                });
              },
              tooltip: 'Done',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _currentLine = [details.localPosition];
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _currentLine.add(details.localPosition);
                });
              },
              onPanEnd: (_) {
                setState(() {
                  _lines.add(DrawnLine(
                    points: _currentLine,
                    color: _isErasing ? Colors.white : _selectedColor,
                    strokeWidth: _isErasing ? _strokeWidth * 3 : _strokeWidth,
                  ));
                  _currentLine = [];
                });
              },
              child: RepaintBoundary(
                key: _repaintBoundaryKey,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: DrawingPainter(_lines, _currentLine, _selectedColor, _strokeWidth),
                ),
              ),
            ),
          ),
          if (_result.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Result: $_result',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _updateDrawingSettings(isErasing: false),
                  tooltip: 'Pen',
                ),
                IconButton(
                  icon: const Icon(Icons.cleaning_services),
                  onPressed: () => _updateDrawingSettings(isErasing: true),
                  tooltip: 'Eraser',
                ),
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildColorOption(Colors.white),
                      _buildColorOption(Colors.black),
                      _buildColorOption(Colors.blue),
                      _buildColorOption(Colors.red),
                      _buildColorOption(Colors.green),
                      _buildColorOption(Colors.orange),
                      
                    ],
                  ),
                ),
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
              onPressed: () {
                setState(() {
                  if (_lines.isNotEmpty) {
                    _lines.removeLast();
                  }
                });
              },
              tooltip: 'Undo',
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: () {
                setState(() {
                  // Implement redo functionality
                });
              },
              tooltip: 'Redo',
            ),
            ElevatedButton.icon(
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.calculate),
              label: Text(_isProcessing ? 'Processing...' : 'Calculate'),
              onPressed: _isProcessing ? null : _processDrawing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    final isSelected = _selectedColor == color && !_isErasing;
    return GestureDetector(
      onTap: () {
        _updateDrawingSettings(color: color, isErasing: false);
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 4)]
              : null,
        ),
      ),
    );
  }
}

class DrawnLine {
  final List<Offset?> points;
  final Color color;
  final double strokeWidth;

  DrawnLine({required this.points, required this.color, required this.strokeWidth});
}

class DrawingPainter extends CustomPainter {
  final List<DrawnLine> lines;
  final List<Offset?> currentLine;
  final Color currentColor;
  final double currentStrokeWidth;

  DrawingPainter(this.lines, this.currentLine, this.currentColor, this.currentStrokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    for (var line in lines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.strokeWidth
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      canvas.drawPoints(ui.PointMode.polygon, line.points.whereType<Offset>().toList(), paint);
    }

    final paint = Paint()
      ..color = currentColor
      ..strokeWidth = currentStrokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    if (currentLine.isNotEmpty) {
      canvas.drawPoints(ui.PointMode.polygon, currentLine.whereType<Offset>().toList(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
