class Account {
  final String ownerDni;
  final String ownerName;
  final String numberAccount;
  final int balance;
  final bool active;

  Account({
    required this.ownerDni,
    required this.ownerName,
    required this.numberAccount,
    required this.balance,
    required this.active,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      ownerDni: json['owner_dni'],
      ownerName: json['owner_name'],
      numberAccount: json['number_account'],
      balance: json['balance'],
      active: json['active'],
    );
  }
}
