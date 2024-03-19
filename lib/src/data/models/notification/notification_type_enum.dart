import 'package:freezed_annotation/freezed_annotation.dart';

enum NotificationType {
  @JsonValue('EVENT_STATUS')
  eventStatus('Event status information'),
  @JsonValue('TICKET_PURCHASE')
  ticketPurchase('Ticket purchase information'),
  @JsonValue('TICKET_SALES')
  ticketSales('Ticket sales report'),
  @JsonValue('TICKET_REFUND_REQUEST')
  ticketRefundRequest('Ticket refund requests'),
  @JsonValue('TICKET_REFUND_STATUS')
  ticketRefundStatus('Refund request status'),
  @JsonValue('WITHDRAW_STATUS')
  withdrawStatus('Withdrawal status'),
  @JsonValue('OTHER')
  other('Information');

  final String title;

  const NotificationType(this.title);
}
