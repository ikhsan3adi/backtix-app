part of 'ticket_sales_cubit.dart';

@freezed
class TicketSalesState with _$TicketSalesState {
  const factory TicketSalesState.initial() = _Initial;
  const factory TicketSalesState.loading() = _Loading;
  const factory TicketSalesState.loaded(
    TicketPurchasesByTicketModel purchasesWithTicket, {
    required TicketPurchaseQuery query,
    required String ticketId,
    @Default(false) bool hasReachedMax,
    Exception? exception,
  }) = _Loaded;
}
