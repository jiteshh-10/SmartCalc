import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = 'AIzaSyBv4k-pJRnVUKqpI63OAwToFR8ZMwRhh70';
  static const String baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  // Process an image for calculation using the Gemini API
  Future<String> processImage(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [{
            'parts': [{
              'inlineData': {
                'mimeType': 'image/png',
                'data': base64Image
              }
            }]
          }],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Failed to process image');
      }
    } catch (e) {
      throw Exception('Error processing image: $e');
    }
  }

  // Process text input for calculation using the Gemini API
  Future<String> processText(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [{
            'parts': [{
              'text': text
            }]
          }],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Failed to process text');
      }
    } catch (e) {
      throw Exception('Error processing text: $e');
    }
  }

  void dispose() {}
}
