import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_calc/models/calculation.dart';
import 'package:smart_calc/services/gemini_service.dart';

class CalculationProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final SharedPreferences _prefs;
  List<Calculation> _history = [];
  static const String _historyKey = 'calculation_history';

  CalculationProvider(this._prefs) {
    _loadHistory();
  }

  List<Calculation> get history => _history;

  Future<void> _loadHistory() async {
    final historyJson = _prefs.getStringList(_historyKey) ?? [];
    _history = historyJson
        .map((json) => Calculation.fromJson(jsonDecode(json)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final historyJson = _history
        .map((calc) => jsonEncode(calc.toJson()))
        .toList();
    await _prefs.setStringList(_historyKey, historyJson);
  }

  Future<String> processDrawing(String description) async {
    final result = await _geminiService.processDrawing(description);
    _addToHistory(description, result, CalculationType.draw);
    return result;
  }

  Future<String> processVoiceInput(String voiceText) async {
    final result = await _geminiService.processVoiceInput(voiceText);
    _addToHistory(voiceText, result, CalculationType.voice);
    return result;
  }

  Future<String> getStepByStepSolution(String problem) async {
    final result = await _geminiService.getStepByStepSolution(problem);
    _addToHistory(problem, result, CalculationType.stepByStep);
    return result;
  }

  Future<String> generateGraphData(String expression) async {
    final result = await _geminiService.generateGraphData(expression);
    _addToHistory(expression, result, CalculationType.graph);
    return result;
  }

  void _addToHistory(String input, String output, CalculationType type) {
    final calculation = Calculation(
      input: input,
      output: output,
      type: type,
      timestamp: DateTime.now(),
    );
    _history.insert(0, calculation);
    _saveHistory();
    notifyListeners();
  }

  void deleteHistoryItem(int index) {
    _history.removeAt(index);
    _saveHistory();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }
}