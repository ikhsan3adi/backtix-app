part of 'ticket_order_bloc.dart';

@freezed
class TicketOrderState with _$TicketOrderState {
  const factory TicketOrderState.initial() = _Initial;
  const factory TicketOrderState.loading() = _Loading;
  const factory TicketOrderState.loaded(
    EventModel? event, {
    @Default(false) bool? orderSuccess,
    Exception? exception,
  }) = _Loaded;
}
