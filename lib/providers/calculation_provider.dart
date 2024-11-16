import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:smart_calc/models/calculation_history.dart';
import 'package:smart_calc/services/gemini_service.dart';

class CalculationProvider with ChangeNotifier {
  final SharedPreferences prefs;
  final GeminiService _geminiService;
  
  List<CalculationHistory> _history = [];
  String _currentExpression = '';
  String _currentResult = '';
  bool _isProcessing = false;

  // Constructor with dependency injection
  CalculationProvider(this.prefs) : _geminiService = GeminiService() {
    _loadHistory();
  }

  // Getters
  List<CalculationHistory> get history => _history;
  String get currentExpression => _currentExpression;
  String get currentResult => _currentResult;
  bool get isProcessing => _isProcessing;

  // Load history from SharedPreferences
  Future<void> _loadHistory() async {
    try {
      final historyJson = prefs.getStringList('calculation_history') ?? [];
      _history = historyJson
          .map((item) => CalculationHistory.fromMap(json.decode(item)))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading history: $e');
      _history = [];
    }
  }

  // Save history to SharedPreferences
  Future<void> _saveHistory() async {
    try {
      final historyJson = _history
          .map((item) => json.encode(item.toMap()))
          .toList();
      await prefs.setStringList('calculation_history', historyJson);
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  // Add calculation to history with retry mechanism
  Future<void> addToHistory(String expression, String result, String type) async {
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final calculation = CalculationHistory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          expression: expression,
          result: result,
          timestamp: DateTime.now(),
          type: type,
        );

        _history.insert(0, calculation);
        await _saveHistory();
        notifyListeners();
        break;
      } catch (e) {
        retryCount++;
        if (retryCount == maxRetries) {
          debugPrint('Failed to add calculation to history after $maxRetries attempts');
        } else {
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        }
      }
    }
  }

  // Delete history item
  Future<void> deleteHistoryItem(String id) async {
    _history.removeWhere((item) => item.id == id);
    await _saveHistory();
    notifyListeners();
  }

  // Clear all history
  Future<void> clearHistory() async {
    _history.clear();
    await _saveHistory();
    notifyListeners();
  }

  // Update current expression
  void updateExpression(String expression) {
    _currentExpression = expression;
    notifyListeners();
  }

  // Update current result
  void updateResult(String result) {
    _currentResult = result;
    notifyListeners();
  }

  // Process drawn mathematical expression
  Future<String> processDrawing(String description) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Create a specific prompt for mathematical expressions
      final prompt = '''
      Process this handwritten mathematical expression extracted via OCR: "$description"

      Rules:
      1. Identify and correct common OCR mistakes in mathematical symbols:
         - 'x' or '×' should be treated as multiplication (*)
         - '÷' should be treated as division (/)
         - '−' or '--' should be treated as subtraction (-)
      2. Calculate the result with proper operator precedence
      3. Return only the numerical result
      4. If the expression is invalid, explain why

      Please provide the result or error explanation.
      ''';

      final result = await _geminiService.processText(prompt);
      
      // Clean and validate the result
      final cleanResult = _cleanCalculationResult(result);
      
      // Add to history only if it's a valid calculation
      if (_isValidCalculationResult(cleanResult)) {
        await addToHistory(description, cleanResult, "draw");
      }

      updateResult(cleanResult);
      return cleanResult;

    } catch (e) {
      final errorMessage = 'Error: ${e.toString()}';
      updateResult(errorMessage);
      return errorMessage;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Process voice input
  Future<String> processVoiceInput(String voiceInput) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final prompt = '''
      Process this voice-transcribed mathematical expression: "$voiceInput"
      
      Rules:
      1. Convert written numbers and operators to mathematical expression
      2. Calculate the result with proper operator precedence
      3. Return only the numerical result
      4. If the expression is invalid, explain why
      
      Please provide the result or error explanation.
      ''';

      final result = await _geminiService.processText(prompt);
      
      final cleanResult = _cleanCalculationResult(result);
      
      if (_isValidCalculationResult(cleanResult)) {
        await addToHistory(voiceInput, cleanResult, "voice");
      }

      updateResult(cleanResult);
      return cleanResult;

    } catch (e) {
      final errorMessage = 'Error: ${e.toString()}';
      updateResult(errorMessage);
      return errorMessage;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Clean calculation result
  String _cleanCalculationResult(String result) {
    // Remove any additional explanations and keep only the numerical result
    final numberMatch = RegExp(r'-?\d*\.?\d+').firstMatch(result);
    if (numberMatch != null) {
      return numberMatch.group(0) ?? result;
    }
    
    // If no number is found, return the original result (might be an error message)
    return result.trim();
  }

  // Validate calculation result
  bool _isValidCalculationResult(String result) {
    return RegExp(r'^-?\d*\.?\d+$').hasMatch(result);
  }

  // Dispose resources
  @override
  void dispose() {
    _geminiService.dispose();
    super.dispose();
  }
}