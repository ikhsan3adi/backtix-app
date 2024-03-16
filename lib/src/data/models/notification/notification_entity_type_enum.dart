import 'package:freezed_annotation/freezed_annotation.dart';

enum NotificationEntityType {
  @JsonValue('EVENT')
  event,
  @JsonValue('TICKET')
  ticket,
  @JsonValue('PURCHASE')
  purchase,
  @JsonValue('WITHDRAW_REQUEST')
  withdrawRequest,
}
