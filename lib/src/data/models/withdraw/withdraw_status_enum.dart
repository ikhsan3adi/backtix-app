import 'package:freezed_annotation/freezed_annotation.dart';

enum WithdrawStatus {
  @JsonValue('PENDING')
  pending('Pending'),
  @JsonValue('COMPLETED')
  completed('Completed'),
  @JsonValue('REJECTED')
  rejected('Rejected');

  final String value;

  const WithdrawStatus(this.value);
}
