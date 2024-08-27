

String maskAccountNumber(String accountNumber) {
  if (accountNumber.length != 10) {
    return 'Invalid account number';
  }

  String visibleDigits = accountNumber.substring(accountNumber.length - 6); // Muestra los últimos 6 dígitos
  String maskedDigits = accountNumber.substring(0, 4).replaceAll(RegExp(r'\d'), 'x'); // Oculta los primeros 4 dígitos
  return '$maskedDigits$visibleDigits';
}