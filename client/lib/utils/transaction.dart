import 'package:intl/intl.dart'; // Asegúrate de añadir esta dependencia en pubspec.yaml

class Transaction {
  final String operation;
  final double import;
  final DateTime createDate; // Cambiado a DateTime para facilitar el formateo

  Transaction({
    required this.operation,
    required this.import,
    required this.createDate,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      operation: json['operation'] as String? ?? '',
      import: (json['import'] as num? ?? 0).toDouble(),
      createDate: DateTime.parse(json['create_date'] as String),
    );
  }

  String getFormattedDate() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(createDate);
  }
}
