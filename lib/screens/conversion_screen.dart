import 'package:flutter/material.dart';

class ConversionScreen extends StatefulWidget {
  const ConversionScreen({super.key});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  String _selectedCategory = 'Length';
  String _fromUnit = 'Meters';
  String _toUnit = 'Feet';
  final TextEditingController _valueController = TextEditingController();
  String _result = '';

  final Map<String, List<String>> _categories = {
    'Length': ['Meters', 'Feet', 'Inches', 'Kilometers', 'Miles'],
    'Weight': ['Kilograms', 'Pounds', 'Ounces', 'Grams'],
    'Temperature': ['Celsius', 'Fahrenheit', 'Kelvin'],
    'Area': ['Square Meters', 'Square Feet', 'Acres', 'Hectares'],
  };

  void _convert() {
    double? inputValue = double.tryParse(_valueController.text);
    if (inputValue == null) {
      setState(() => _result = 'Invalid input');
      return;
    }

    double result = _performConversion(inputValue);
    setState(() => _result = result.toStringAsFixed(2));
  }

  double _performConversion(double value) {
    // This is a simplified example - you'll need to implement actual conversion logic
    if (_fromUnit == 'Meters' && _toUnit == 'Feet') {
      return value * 3.28084;
    }
    // Add other conversion logic here
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unit Converter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: _categories.keys.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                  _fromUnit = _categories[_selectedCategory]![0];
                  _toUnit = _categories[_selectedCategory]![1];
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _fromUnit,
                    isExpanded: true,
                    items: _categories[_selectedCategory]!.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => _fromUnit = newValue!);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.arrow_forward),
                ),
                Expanded(
                  child: DropdownButton<String>(
                    value: _toUnit,
                    isExpanded: true,
                    items: _categories[_selectedCategory]!.map((String unit) {
                      return DropdownMenuItem<String>(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => _toUnit = newValue!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter value in $_fromUnit',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _convert,
              child: const Text('Convert'),
            ),
            const SizedBox(height: 16),
            Text(
              _result.isNotEmpty ? '$_result $_toUnit' : '',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}