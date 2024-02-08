part of 'ticket_purchase_bloc.dart';

@freezed
class TicketPurchaseState with _$TicketPurchaseState {
  const factory TicketPurchaseState.initial() = _Initial;
  const factory TicketPurchaseState.loading() = _Loading;
  const factory TicketPurchaseState.loaded(
    EventModel? event, {
    @Default(false) bool? orderSuccess,
    Exception? error,
  }) = _Loaded;
}
