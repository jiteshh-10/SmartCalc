class Calculation {
  final String expression;
  final String result;
  final String type;

  Calculation({
    required this.expression,
    required this.result,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'expression': expression,
      'result': result,
      'type': type,
    };
  }

  factory Calculation.fromMap(Map<String, dynamic> map) {
    return Calculation(
      expression: map['expression'] ?? '',
      result: map['result'] ?? '',
      type: map['type'] ?? '',
    );
  }
}
