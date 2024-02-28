part of 'event_ticket_sales_cubit.dart';

@freezed
class EventTicketSalesState with _$EventTicketSalesState {
  const factory EventTicketSalesState.initial() = _Initial;
  const factory EventTicketSalesState.loading() = _Loading;
  const factory EventTicketSalesState.loaded(
    List<TicketPurchaseModel> purchases, {
    required TicketPurchaseQuery query,
    required String eventId,
    @Default(false) bool hasReachedMax,
    Exception? exception,
  }) = _Loaded;
}
