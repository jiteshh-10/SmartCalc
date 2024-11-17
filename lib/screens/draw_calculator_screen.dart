import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

enum BrushType { normal, calligraphy, highlighter }

class DrawingPoint {
  final Offset point;
  final Paint paint;
  final double pressure;

  DrawingPoint({
    required this.point,
    required this.paint,
    this.pressure = 1.0,
  });
}

class DrawCalculatorScreen extends StatefulWidget {
  const DrawCalculatorScreen({super.key});

  @override
  _DrawCalculatorScreenState createState() => _DrawCalculatorScreenState();
}

class _DrawCalculatorScreenState extends State<DrawCalculatorScreen> {
  List<DrawingPoint?> points = [];
  List<List<DrawingPoint?>> history = [];
  int historyIndex = -1;
  Color selectedColor = Colors.white;
  double strokeWidth = 3.0;
  String result = '';
  bool isCalculating = false;
  BrushType currentBrushType = BrushType.normal;
  List<Offset> currentStroke = [];

  final colors = [
    Colors.white,
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
  ];

  // Initialize Gemini AI
  late final GenerativeModel model;

  @override
  void initState() {
    super.initState();
    model = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: 'AIzaSyBv4k-pJRnVUKqpI63OAwToFR8ZMwRhh70',
    );
  }

  Paint _getBrushPaint(double pressure) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    switch (currentBrushType) {
      case BrushType.normal:
        paint
          ..color = selectedColor
          ..strokeWidth = strokeWidth * pressure;
      case BrushType.calligraphy:
        paint
          ..color = selectedColor
          ..strokeWidth = strokeWidth * pressure * 2
          ..strokeCap = StrokeCap.square
          ..strokeJoin = StrokeJoin.bevel;
      case BrushType.highlighter:
        paint
          ..color = selectedColor.withOpacity(0.3)
          ..strokeWidth = strokeWidth * 2
          ..blendMode = BlendMode.screen;
    }

    return paint;
  }

  List<Offset> smoothPath(List<Offset> points) {
    if (points.length < 3) return points;

    List<Offset> smoothPoints = [];

    // Implement Catmull-Rom spline
    for (int i = 0; i < points.length - 3; i++) {
      Offset p0 = points[i];
      Offset p1 = points[i + 1];
      Offset p2 = points[i + 2];
      Offset p3 = points[i + 3];

      // Add points between p1 and p2 using Catmull-Rom interpolation
      for (double t = 0; t < 1; t += 0.1) {
        double t2 = t * t;
        double t3 = t2 * t;

        double x = 0.5 *
            ((2 * p1.dx) +
                (-p0.dx + p2.dx) * t +
                (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * t2 +
                (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * t3);

        double y = 0.5 *
            ((2 * p1.dy) +
                (-p0.dy + p2.dy) * t +
                (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * t2 +
                (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * t3);

        smoothPoints.add(Offset(x, y));
      }
    }

    return smoothPoints;
  }

  void onPointerDown(PointerDownEvent event) {
    final pressure = event.pressure;
    final paint = _getBrushPaint(pressure);

    final newPoint = DrawingPoint(
      point: event.localPosition,
      paint: paint,
      pressure: pressure,
    );

    setState(() {
      points.add(newPoint);
      currentStroke = [event.localPosition];

      // Clear redo history when new drawing starts
      if (historyIndex < history.length - 1) {
        history = history.sublist(0, historyIndex + 1);
      }
    });
  }

  void onPointerMove(PointerMoveEvent event) {
    final pressure = event.pressure;
    final paint = _getBrushPaint(pressure);

    currentStroke.add(event.localPosition);

    // Apply smoothing when we have enough points
    if (currentStroke.length >= 4) {
      List<Offset> smoothedPoints = smoothPath(currentStroke);

      for (var smoothedPoint in smoothedPoints) {
        final newPoint = DrawingPoint(
          point: smoothedPoint,
          paint: paint,
          pressure: pressure,
        );
        points.add(newPoint);
      }

      // Keep only the last few points for next smoothing operation
      currentStroke = currentStroke.sublist(currentStroke.length - 3);
    }

    setState(() {});
  }

  void onPointerUp(PointerUpEvent event) {
    setState(() {
      points.add(null); // Add null to separate lines
      currentStroke.clear();
      // Save current state to history
      history.add(List.from(points));
      historyIndex++;
    });
  }

  void undo() {
    if (historyIndex > 0) {
      setState(() {
        historyIndex--;
        points = List.from(history[historyIndex]);
      });
    } else if (historyIndex == 0) {
      setState(() {
        historyIndex--;
        points.clear();
      });
    }
  }

  void redo() {
    if (historyIndex < history.length - 1) {
      setState(() {
        historyIndex++;
        points = List.from(history[historyIndex]);
      });
    }
  }

  void clear() {
    setState(() {
      points.clear();
      currentStroke.clear();
      history.add(List.from(points));
      historyIndex = history.length - 1;
    });
  }

  Future<void> calculateDrawing() async {
    if (points.isEmpty) return;

    setState(() {
      isCalculating = true;
    });

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      canvas.drawRect(
        Rect.fromLTWH(0, 0, 400, 400),
        Paint()..color = Colors.black87,
      );

      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          canvas.drawLine(
            points[i]!.point,
            points[i + 1]!.point,
            points[i]!.paint,
          );
        } else if (points[i] != null && points[i + 1] == null) {
          canvas.drawPoints(
            ui.PointMode.points,
            [points[i]!.point],
            points[i]!.paint,
          );
        }
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(400, 400);
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

      if (pngBytes == null) {
        throw Exception('Failed to convert drawing to image');
      }

// Create content for Gemini API
      final content = {
        'text':
            'Analyze this image and identify any mathematical expressions. Calculate the result and return only the numerical answer.',
        'image': pngBytes,
      };

// Generate content using the new API

      final response =
          await model.generateContent(content as Iterable<Content>);
      final responseText = response.text;

      setState(() {
        result = responseText ?? 'Unable to calculate';
        isCalculating = false;
      });
    } catch (e) {
      setState(() {
        result = 'Error: $e';
        isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Draw to Calculate'),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.black87,
              child: Listener(
                onPointerDown: onPointerDown,
                onPointerMove: onPointerMove,
                onPointerUp: onPointerUp,
                child: CustomPaint(
                  painter: DrawingPainter(points: points),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          if (result.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Result: $result',
                style: TextStyle(fontSize: 24),
              ),
            ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.black87,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: clear,
              ),
              ...colors.map((color) => _buildColorButton(color)).toList(),
              Expanded(
                child: Slider(
                  value: strokeWidth,
                  min: 1,
                  max: 20,
                  onChanged: (value) {
                    setState(() {
                      strokeWidth = value;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              DropdownButton<BrushType>(
                value: currentBrushType,
                items: BrushType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (BrushType? value) {
                  if (value != null) {
                    setState(() {
                      currentBrushType = value;
                    });
                  }
                },
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.undo),
                onPressed: points.isEmpty ? null : undo,
              ),
              IconButton(
                icon: Icon(Icons.redo),
                onPressed: historyIndex < history.length - 1 ? redo : null,
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.calculate),
                label: Text('Calculate'),
                onPressed: isCalculating ? null : calculateDrawing,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selectedColor == color ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          points[i]!.point,
          points[i + 1]!.point,
          points[i]!.paint,
        );
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(
          ui.PointMode.points,
          [points[i]!.point],
          points[i]!.paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return true;
  }
}
