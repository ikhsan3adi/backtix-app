enum WithdrawMethod {
  transfer('Transfer'),
  gopay('Gopay'),
  pulsa('Pulsa'),

  other('Other');

  final String value;

  const WithdrawMethod(this.value);
}
