import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() => _isListening = false);
          _processVoiceInput();
        }
      },
      onError: (error) => print('Error: $error'),
    );
    if (!mounted) return;
    
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
    }
  }

  Future<void> _processVoiceInput() async {
    if (_transcription.isEmpty) return;

    setState(() => _isProcessing = true);
    try {
      final result = await context.read<CalculationProvider>()
          .processVoiceInput(_transcription);
      setState(() => _result = result);
    } catch (e) {
      setState(() => _result = 'Error processing voice input: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

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

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            onPressed: _result.isNotEmpty ? () {
              // TODO: Implement graph view
            } : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                      _transcription.isEmpty ? 'Tap the microphone to start' : _transcription,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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
            Center(
              child: GestureDetector(
                onTapDown: (_) => _startListening(),
                onTapUp: (_) => _stopListening(),
                onTapCancel: () => _stopListening(),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isListening 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 40,
                    color: _isListening 
                        ? Theme.of(context).colorScheme.onPrimary 
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