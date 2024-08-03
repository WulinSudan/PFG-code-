class Account {
  final String ownerDni;
  final String ownerName;
  final String numberAccount;
  final double balance;
  final bool active;
  bool isSelected; // Nuevo campo para indicar si la cuenta está seleccionada
  final double maxPay;
  final double maxPayDay;

  Account({
    required this.ownerDni,
    required this.ownerName,
    required this.numberAccount,
    required this.balance,
    required this.active,
    this.isSelected = false, // Por defecto, la cuenta no está seleccionada
    required this.maxPay,
    required this.maxPayDay,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    // Utiliza el operador de asignación condicional para manejar valores nulos
    return Account(
      ownerDni: json['owner_dni'] as String? ?? '', // Proporciona un valor predeterminado
      ownerName: json['owner_name'] as String? ?? '', // Proporciona un valor predeterminado
      numberAccount: json['number_account'] as String? ?? '', // Proporciona un valor predeterminado
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0, // Proporciona un valor predeterminado
      active: json['active'] as bool? ?? false, // Proporciona un valor predeterminado
      isSelected: json['is_selected'] as bool? ?? false, // Añadido para manejar el nuevo campo
      maxPay: (json['maximum_amount_once'] as num?)?.toDouble() ?? 0.0,
      maxPayDay: (json['maximum_amount_day'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_dni': ownerDni,
      'owner_name': ownerName,
      'number_account': numberAccount,
      'balance': balance,
      'active': active,
      'is_selected': isSelected, // Añadido para manejar el nuevo campo
      'maximum_amount_once': maxPay,
      'maximum_amount_day': maxPayDay,
    };
  }
}
