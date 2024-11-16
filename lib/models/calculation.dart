import 'package:equatable/equatable.dart';

enum CalculationType {
  draw,
  voice,
  stepByStep,
  graph,
  conversion
}

class Calculation extends Equatable {
  final String input;
  final String output;
  final CalculationType type;
  final DateTime timestamp;

  const Calculation({
    required this.input,
    required this.output,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'input': input,
      'output': output,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Calculation.fromJson(Map<String, dynamic> json) {
    return Calculation(
      input: json['input'],
      output: json['output'],
      type: CalculationType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  List<Object> get props => [input, output, type, timestamp];
}