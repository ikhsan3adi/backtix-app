part of 'ticket_purchase_refund_cubit.dart';

@freezed
class TicketPurchaseRefundState with _$TicketPurchaseRefundState {
  const factory TicketPurchaseRefundState.initial() = _Initial;
  const factory TicketPurchaseRefundState.loading() = _Loading;
  const factory TicketPurchaseRefundState.success(
    TicketPurchaseModel ticketPurchase,
  ) = _Success;
  const factory TicketPurchaseRefundState.failed(
    DioException exception,
  ) = _Failed;
}
