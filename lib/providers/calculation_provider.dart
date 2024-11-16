import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:smart_calc/models/calculation_history.dart';
import 'package:smart_calc/services/gemini_service.dart'; // Import GeminiService

class CalculationProvider with ChangeNotifier {
  final SharedPreferences prefs;
  final GeminiService _geminiService = GeminiService(); // Initialize GeminiService

  List<CalculationHistory> _history = [];
  String _currentExpression = '';
  String _currentResult = '';

  // Constructor with initialization of calculation history from SharedPreferences
  CalculationProvider(this.prefs) {
    _loadHistory();
  }

  // Getters for accessing history, current expression, and current result
  List<CalculationHistory> get history => _history;
  String get currentExpression => _currentExpression;
  String get currentResult => _currentResult;

  // Load calculation history from SharedPreferences
  Future<void> _loadHistory() async {
    final historyJson = prefs.getStringList('calculation_history') ?? [];
    _history = historyJson
        .map((item) => CalculationHistory.fromMap(json.decode(item)))
        .toList();
    notifyListeners();
  }

  // Add a new calculation to the history
  Future<void> addToHistory(String expression, String result, String type) async {
    final calculation = CalculationHistory(
      id: DateTime.now().toString(),
      expression: expression,
      result: result,
      timestamp: DateTime.now(),
      type: type,
    );

    // Add the new calculation to the beginning of the list
    _history.insert(0, calculation);
    await _saveHistory();
    notifyListeners();
  }

  // Delete a specific item from history by its ID
  Future<void> deleteHistoryItem(String id) async {
    _history.removeWhere((item) => item.id == id);
    await _saveHistory();
    notifyListeners();
  }

  // Clear all calculation history
  Future<void> clearHistory() async {
    _history.clear();
    await _saveHistory();
    notifyListeners();
  }

  // Save the current calculation history to SharedPreferences
  Future<void> _saveHistory() async {
    final historyJson = _history
        .map((item) => json.encode(item.toMap()))
        .toList();
    await prefs.setStringList('calculation_history', historyJson);
  }

  // Update the current expression (e.g., for displaying while the user types)
  void updateExpression(String expression) {
    _currentExpression = expression;
    notifyListeners();
  }

  // Update the current result after processing a calculation
  void updateResult(String result) {
    _currentResult = result;
    notifyListeners();
  }

  // Method to process the drawing description using the Gemini API
  Future<String> processDrawing(String description) async {
    try {
      final result = await _geminiService.processText(description);

      // Update the current result with the response from the Gemini API
      updateResult(result);

      // Add the calculation to the history
      await addToHistory(description, result, "draw");

      return result;
    } catch (e) {
      return "Error processing drawing: $e";
    }
  }

  // Method to process voice input using the Gemini API
  Future<String> processVoiceInput(String voiceInput) async {
    try {
      final result = await _geminiService.processText(voiceInput);

      // Update the current result with the response from the Gemini API
      updateResult(result);

      // Add the calculation to the history
      await addToHistory(voiceInput, result, "voice");

      return result;
    } catch (e) {
      return "Error processing voice input: $e";
    }
  }
}
