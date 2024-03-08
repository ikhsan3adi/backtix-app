import 'package:freezed_annotation/freezed_annotation.dart';

enum WithdrawFrom {
  @JsonValue('BALANCE')
  balance('Balance'),
  @JsonValue('REVENUE')
  revenue('Revenue');

  final String value;

  const WithdrawFrom(this.value);
}
