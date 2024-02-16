part of 'ticket_order_bloc.dart';

@freezed
class TicketOrderEvent with _$TicketOrderEvent {
  const factory TicketOrderEvent.init({required String eventId}) = _Init;
  const factory TicketOrderEvent.createTicketOrder(
    CreateTicketOrderState order,
  ) = _CreateOrder;
}
