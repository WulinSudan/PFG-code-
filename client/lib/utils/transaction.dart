// transaction.dart
class Transaction {
  final String operation;
  final double import;
  final String createDate; // Usa String para la fecha

  Transaction({
    required this.operation,
    required this.import,
    required this.createDate,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      operation: json['operation'] as String? ?? '', // Usa un valor predeterminado en caso de null
      import: (json['import'] as num? ?? 0).toDouble(), // Usa un valor predeterminado en caso de null
      createDate: json['create_date'] as String? ?? '', // Usa un valor predeterminado en caso de null
    );
  }
}
