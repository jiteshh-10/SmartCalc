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
    if (_selectedCategory == 'Length') {
      return _convertLength(value);
    } else if (_selectedCategory == 'Weight') {
      return _convertWeight(value);
    } else if (_selectedCategory == 'Temperature') {
      return _convertTemperature(value);
    } else if (_selectedCategory == 'Area') {
      return _convertArea(value);
    }
    return value;
  }

  // Length Conversion Logic
  double _convertLength(double value) {
    if (_fromUnit == 'Meters' && _toUnit == 'Feet') {
      return value * 3.28084;
    } else if (_fromUnit == 'Feet' && _toUnit == 'Meters') {
      return value / 3.28084;
    } else if (_fromUnit == 'Meters' && _toUnit == 'Kilometers') {
      return value / 1000;
    } else if (_fromUnit == 'Kilometers' && _toUnit == 'Meters') {
      return value * 1000;
    } else if (_fromUnit == 'Miles' && _toUnit == 'Kilometers') {
      return value * 1.60934;
    } else if (_fromUnit == 'Kilometers' && _toUnit == 'Miles') {
      return value / 1.60934;
    } else if (_fromUnit == 'Inches' && _toUnit == 'Meters') {
      return value * 0.0254;
    } else if (_fromUnit == 'Meters' && _toUnit == 'Inches') {
      return value / 0.0254;
    }
    return value; // If units are the same
  }

  // Weight Conversion Logic
  double _convertWeight(double value) {
    if (_fromUnit == 'Kilograms' && _toUnit == 'Pounds') {
      return value * 2.20462;
    } else if (_fromUnit == 'Pounds' && _toUnit == 'Kilograms') {
      return value / 2.20462;
    } else if (_fromUnit == 'Kilograms' && _toUnit == 'Ounces') {
      return value * 35.274;
    } else if (_fromUnit == 'Ounces' && _toUnit == 'Kilograms') {
      return value / 35.274;
    } else if (_fromUnit == 'Pounds' && _toUnit == 'Ounces') {
      return value * 16;
    } else if (_fromUnit == 'Ounces' && _toUnit == 'Pounds') {
      return value / 16;
    } else if (_fromUnit == 'Grams' && _toUnit == 'Kilograms') {
      return value / 1000;
    } else if (_fromUnit == 'Kilograms' && _toUnit == 'Grams') {
      return value * 1000;
    }
    return value; // If units are the same
  }

  // Temperature Conversion Logic
  double _convertTemperature(double value) {
    if (_fromUnit == 'Celsius' && _toUnit == 'Fahrenheit') {
      return value * 9 / 5 + 32;
    } else if (_fromUnit == 'Fahrenheit' && _toUnit == 'Celsius') {
      return (value - 32) * 5 / 9;
    } else if (_fromUnit == 'Celsius' && _toUnit == 'Kelvin') {
      return value + 273.15;
    } else if (_fromUnit == 'Kelvin' && _toUnit == 'Celsius') {
      return value - 273.15;
    } else if (_fromUnit == 'Fahrenheit' && _toUnit == 'Kelvin') {
      return (value - 32) * 5 / 9 + 273.15;
    } else if (_fromUnit == 'Kelvin' && _toUnit == 'Fahrenheit') {
      return (value - 273.15) * 9 / 5 + 32;
    }
    return value; // If units are the same
  }

  // Area Conversion Logic
  double _convertArea(double value) {
    if (_fromUnit == 'Square Meters' && _toUnit == 'Square Feet') {
      return value * 10.7639;
    } else if (_fromUnit == 'Square Feet' && _toUnit == 'Square Meters') {
      return value / 10.7639;
    } else if (_fromUnit == 'Acres' && _toUnit == 'Square Meters') {
      return value * 4046.86;
    } else if (_fromUnit == 'Square Meters' && _toUnit == 'Acres') {
      return value / 4046.86;
    } else if (_fromUnit == 'Square Feet' && _toUnit == 'Acres') {
      return value / 43560;
    } else if (_fromUnit == 'Acres' && _toUnit == 'Square Feet') {
      return value * 43560;
    } else if (_fromUnit == 'Hectares' && _toUnit == 'Square Meters') {
      return value * 10000;
    } else if (_fromUnit == 'Square Meters' && _toUnit == 'Hectares') {
      return value / 10000;
    }
    return value; // If units are the same
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
