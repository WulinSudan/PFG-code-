class Account {
  final String ownerDni;
  final String ownerName;
  final String numberAccount;
  final double balance;
  final bool active;
  bool isSelected; // Nuevo campo para indicar si la cuenta está seleccionada

  Account({
    required this.ownerDni,
    required this.ownerName,
    required this.numberAccount,
    required this.balance,
    required this.active,
    this.isSelected = false, // Por defecto, la cuenta no está seleccionada
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      ownerDni: json['owner_dni'],
      ownerName: json['owner_name'],
      numberAccount: json['number_account'],
      balance: (json['balance'] as num).toDouble(),
      active: json['active'],
    );
  }
}
