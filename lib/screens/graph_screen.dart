import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final TextEditingController _expressionController = TextEditingController();
  List<FlSpot> _spots = [];
  bool _loading = false;
  String _errorMessage = '';

  // Define the range for both X and Y axes
  final double _minX = -10;
  final double _maxX = 10;
  final double _minY = -10;
  final double _maxY = 10;

  // MathJS API endpoint
  final String _mathJsApiUrl = 'https://api.mathjs.org/v4/';

  // Generate points based on the mathematical expression
  Future<void> _generatePoints() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
      _spots.clear(); // Clear previous spots
    });

    // Loop through the X axis range and compute Y for each point
    for (double x = _minX; x <= _maxX; x += 0.1) {
      try {
        double y = await _evaluateExpression(x);
        if (y.isFinite) {
          setState(() {
            _spots.add(FlSpot(x, y));
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error evaluating expression: $e';
        });
      }
    }

    setState(() {
      _loading = false;
    });
  }

  // Evaluate the mathematical expression via the MathJS API
  Future<double> _evaluateExpression(double x) async {
    // Replace 'x' in the expression with the actual x value
    String expression = _expressionController.text.replaceAll('x', x.toString());

    final response = await http.post(
      Uri.parse(_mathJsApiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "expr": expression,
      }),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result.containsKey('result')) {
        return double.tryParse(result['result'].toString()) ?? 0.0;
      } else {
        throw Exception('Invalid result in response');
      }
    } else {
      throw Exception('API request failed with status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Graph')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input field for the mathematical expression
            TextField(
              controller: _expressionController,
              decoration: const InputDecoration(
                labelText: 'Enter function (e.g., x^2, sin(x))',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generatePoints,
              child: const Text('Plot Graph'),
            ),
            // Show loading or error message
            if (_loading)
              const CircularProgressIndicator()
            else if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            // Check if there are valid points to display the graph
            Expanded(
              child: _spots.isNotEmpty
                  ? LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 32),
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
                        lineBarsData: [
                          LineChartBarData(
                            spots: _spots, // List of spots to plot
                            isCurved: true, // Makes the line smooth
                            color: Colors.blue, // Color of the graph line
                            belowBarData: BarAreaData(show: false), // Hide area under the curve
                            dotData: FlDotData(show: false), // Hide dots at each point
                            aboveBarData: BarAreaData(show: false),  // Hide area under the curve
                          ),
                        ],
                      ),
                    )
                  : Center(child: Text('No data to display', style: TextStyle(fontSize: 18))),
            ),
          ],
        ),
      ),
    );
  }
}
