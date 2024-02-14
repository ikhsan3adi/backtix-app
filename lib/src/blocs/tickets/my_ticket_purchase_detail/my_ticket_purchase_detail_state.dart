part of 'my_ticket_purchase_detail_cubit.dart';

@freezed
class MyTicketPurchaseDetailState with _$MyTicketPurchaseDetailState {
  const factory MyTicketPurchaseDetailState.loading() = _Loading;
  const factory MyTicketPurchaseDetailState.loaded(
    TicketPurchaseModel ticketPurchase,
  ) = _Loaded;
  const factory MyTicketPurchaseDetailState.error(
    DioException exception,
  ) = _Error;
}
