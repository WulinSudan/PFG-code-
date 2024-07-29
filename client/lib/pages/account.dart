class Account {
  final String ownerDni;
  final String ownerName;
  final String numberAccount;
  final double balance;
  final bool active;
  bool isSelected; // Nuevo campo para indicar si la cuenta está seleccionada
  final double maxPay; // Cambiado para ser un entero

  Account({
    required this.ownerDni,
    required this.ownerName,
    required this.numberAccount,
    required this.balance,
    required this.active,
    this.isSelected = false, // Por defecto, la cuenta no está seleccionada
    required this.maxPay,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    // Utiliza el operador de asignación condicional para manejar valores nulos
    return Account(
      ownerDni: json['owner_dni'] as String? ?? '', // Proporciona un valor predeterminado
      ownerName: json['owner_name'] as String? ?? '', // Proporciona un valor predeterminado
      numberAccount: json['number_account'] as String? ?? '', // Proporciona un valor predeterminado
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0, // Proporciona un valor predeterminado
      active: json['active'] as bool? ?? false, // Proporciona un valor predeterminado
      maxPay: (json['maximum_amount_once'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_dni': ownerDni,
      'owner_name': ownerName,
      'number_account': numberAccount,
      'balance': balance,
      'active': active,
      'maximum_amount_once': maxPay,
    };
  }
}
