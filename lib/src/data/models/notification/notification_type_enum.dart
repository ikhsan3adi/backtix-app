import 'package:freezed_annotation/freezed_annotation.dart';

enum NotificationType {
  @JsonValue('TICKET_PURCHASE')
  ticketPurchase,
  @JsonValue('TICKET_SALES')
  ticketSales,
  @JsonValue('TICKET_REFUND_REQUEST')
  ticketRefundRequest,
  @JsonValue('TICKET_REFUND_STATUS')
  ticketRefundStatus,
  @JsonValue('WITHDRAW_STATUS')
  withdrawStatus,
  @JsonValue('OTHER')
  other,
}
