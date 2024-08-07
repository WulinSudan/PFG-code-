class Account {
  final String ownerDni;
  final String ownerName;
  final String numberAccount;
  final double balance;
  bool active; // Ahora 'active' no es final, por lo que es mutable.
  bool isSelected; // Nuevo campo para indicar si la cuenta está seleccionada
  final double maxPay;
  final double maxPayDay;
  final String description; // Cambiado a String

  Account({
    required this.ownerDni,
    required this.ownerName,
    required this.numberAccount,
    required this.balance,
    required this.active, // Ya no es final, por lo que puede ser modificado
    this.isSelected = false, // Por defecto, la cuenta no está seleccionada
    required this.maxPay,
    required this.maxPayDay,
    required this.description,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      ownerDni: json['owner_dni'] as String? ?? '',
      ownerName: json['owner_name'] as String? ?? '',
      numberAccount: json['number_account'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      active: json['active'] as bool? ?? false,
      isSelected: json['is_selected'] as bool? ?? false,
      maxPay: (json['maximum_amount_once'] as num?)?.toDouble() ?? 0.0,
      maxPayDay: (json['maximum_amount_day'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '', // Asegúrate de que description sea un String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_dni': ownerDni,
      'owner_name': ownerName,
      'number_account': numberAccount,
      'balance': balance,
      'active': active, // Ahora 'active' puede ser modificado
      'is_selected': isSelected,
      'maximum_amount_once': maxPay,
      'maximum_amount_day': maxPayDay,
      'description': description,
    };
  }
}
