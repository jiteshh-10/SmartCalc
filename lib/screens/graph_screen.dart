import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final TextEditingController _expressionController = TextEditingController();
  List<FlSpot> _spots = [];
  final double _minX = -10;
  final double _maxX = 10;
  final double _minY = -10;
  final double _maxY = 10;

  void _generatePoints() {
    _spots = [];
    for (double x = _minX; x <= _maxX; x += 0.1) {
      try {
        // Simple expression evaluation (you'll need a more robust parser)
        double y = _evaluateExpression(x);
        if (y.isFinite) {
          _spots.add(FlSpot(x, y));
        }
      } catch (e) {
        // Handle parsing errors
      }
    }
    setState(() {});
  }

  double _evaluateExpression(double x) {
    // This is a simple example - you'll want to use a proper math expression parser
    String expr = _expressionController.text.toLowerCase();
    expr = expr.replaceAll('x', x.toString());
    // Add your expression evaluation logic here
    return x * x; // Example: y = x²
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Graph')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _expressionController,
              decoration: const InputDecoration(
                labelText: 'Enter function (e.g., x^2)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generatePoints,
              child: const Text('Plot Graph'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(spots: _spots),
                  ],
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: _minX,
                  maxX: _maxX,
                  minY: _minY,
                  maxY: _maxY,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
