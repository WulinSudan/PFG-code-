class Account {
  final String owner_dni;
  final String owner_name;
  final String account_number;
  final double balance;
  final bool active;

  Account({required this.owner_dni, required this.owner_name, required this.balance, required this.account_number, required this.active});
}