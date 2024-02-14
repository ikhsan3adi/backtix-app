part of 'my_ticket_purchases_bloc.dart';

@freezed
class MyTicketPurchasesEvent with _$MyTicketPurchasesEvent {
  const factory MyTicketPurchasesEvent.getMyTicketPurchases(
    TicketPurchaseQuery query,
  ) = _Get;

  const factory MyTicketPurchasesEvent.getMoreTicketPurchases() = _GetMore;
}
