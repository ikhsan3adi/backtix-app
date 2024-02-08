part of 'ticket_purchase_bloc.dart';

@freezed
class TicketPurchaseEvent with _$TicketPurchaseEvent {
  const factory TicketPurchaseEvent.init({required String eventId}) = _Init;
  const factory TicketPurchaseEvent.createTicketOrder(
    CreateTicketOrderState order,
  ) = _CreateOrder;
}
