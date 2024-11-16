class CalculationHistory {
  final String id;
  final String expression;
  final String result;
  final DateTime timestamp;
  final String type; // 'standard', 'voice', 'draw', etc.

  CalculationHistory({
    required this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expression': expression,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  factory CalculationHistory.fromMap(Map<String, dynamic> map) {
    return CalculationHistory(
      id: map['id'],
      expression: map['expression'],
      result: map['result'],
      timestamp: DateTime.parse(map['timestamp']),
      type: map['type'],
    );
  }
}