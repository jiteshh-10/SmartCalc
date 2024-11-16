import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String apiKey = 'AIzaSyCoOJSQAohg5WVYq_isT3-YJ-0Vfqvt5dI';
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }

  Future<String> processDrawing(String description) async {
    try {
      final prompt = '''
        Process this mathematical expression: $description
        Provide the result in the following format:
        Expression: [the interpreted expression]
        Result: [the calculated result]
        ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Unable to process the expression';
    } catch (e) {
      return 'Error processing the expression: $e';
    }
  }

  Future<String> processVoiceInput(String voiceText) async {
    try {
      final prompt = '''
        Calculate this mathematical expression from voice input: $voiceText
        Provide the result in the following format:
        Expression: [the interpreted expression]
        Result: [the calculated result]
        ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Unable to process the voice input';
    } catch (e) {
      return 'Error processing voice input: $e';
    }
  }

  Future<String> getStepByStepSolution(String problem) async {
    try {
      final prompt = '''
        Solve this mathematical problem step by step: $problem
        Provide a detailed explanation of each step.
        Format the response with clear step numbers and explanations.
        ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Unable to generate solution';
    } catch (e) {
      return 'Error generating solution: $e';
    }
  }

  Future<String> generateGraphData(String expression) async {
    try {
      final prompt = '''
        Generate coordinate points for graphing this mathematical expression: $expression
        Provide points in the following format:
        x,y
        For x values from -10 to 10 in steps of 1
        ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'Unable to generate graph data';
    } catch (e) {
      return 'Error generating graph data: $e';
    }
  }
}