part of 'create_ticket_order_cubit.dart';

@freezed
class CreateTicketOrderState with _$CreateTicketOrderState {
  const CreateTicketOrderState._();

  const factory CreateTicketOrderState({
    required PaymentMethod paymentMethod,
    required List<({TicketModel ticket, int quantity})> purchases,
  }) = _CreateTicketOrderState;

  bool hasTicketId(String ticketId) {
    return purchases.any((e) => e.ticket.id == ticketId);
  }

  CreateTicketOrderModel get toModel => CreateTicketOrderModel(
        paymentMethod: paymentMethod,
        purchases: purchases
            .map((e) => (ticketId: e.ticket.id, quantity: e.quantity))
            .toList(),
      );

  num get totalPrice => purchases.isEmpty
      ? 0
      : purchases
          .filter((e) => e.quantity > 0)
          .map((e) => e.ticket.price * e.quantity)
          .reduce((p, c) => p + c);
}
