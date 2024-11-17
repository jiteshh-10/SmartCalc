import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:smart_calc/providers/calculation_provider.dart';

class VoiceCalculatorScreen extends StatefulWidget {
  const VoiceCalculatorScreen({super.key});

  @override
  State<VoiceCalculatorScreen> createState() => _VoiceCalculatorScreenState();
}

class _VoiceCalculatorScreenState extends State<VoiceCalculatorScreen> {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _transcription = '';
  String _result = '';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  // Initialize the Speech-to-Text engine
  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() => _isListening = false);
          _processVoiceInput();
        }
      },
      onError: (error) {
        _handleSpeechError(error);
      },
    );

    if (!mounted) return;

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
    }
  }

  // Handle the processing of the voice input
  Future<void> _processVoiceInput() async {
    if (_transcription.isEmpty) return;

    try {
      // Call the provider's method to process the voice input using the Gemini API
      final result = await context.read<CalculationProvider>().processVoiceInput(_transcription);
      setState(() => _result = result); // Display the result
    } catch (e) {
      setState(() => _result = 'Error processing voice input: $e');
    } finally {
    }
  }

  // Start the speech recognition
  Future<void> _startListening() async {
    setState(() {
      _transcription = '';
      _result = '';
    });

    if (await _speech.initialize()) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() => _transcription = result.recognizedWords);
        },
      );
    }
  }

  // Stop the speech recognition
  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  // Handle errors during speech recognition
  void _handleSpeechError(SpeechRecognitionError error) {
    setState(() => _isListening = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Speech error: ${error.errorMsg}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: _result.isNotEmpty
                ? () {
                    
                  }
                : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the transcription of the voice input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Voice Input',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _transcription.isEmpty
                          ? 'Tap the microphone to start'
                          : _transcription,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Display the result of the calculation
            if (_result.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Result',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            // Microphone button for initiating voice input
            Center(
              child: GestureDetector(
                onTapDown: (_) => _startListening(),
                onTapUp: (_) => _stopListening(),
                onTapCancel: () => _stopListening(),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _isListening
                        ? Colors.redAccent.withOpacity(0.7) // Change color when listening
                        : Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 50,
                    color: _isListening
                        ? Colors.white
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}
