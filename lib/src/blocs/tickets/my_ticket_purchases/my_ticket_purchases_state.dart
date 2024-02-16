part of 'my_ticket_purchases_bloc.dart';

@freezed
class MyTicketPurchasesState with _$MyTicketPurchasesState {
  const factory MyTicketPurchasesState.initial() = _Initial;
  const factory MyTicketPurchasesState.loading() = _Loading;
  const factory MyTicketPurchasesState.loaded(
    List<TicketPurchasesByEventModel> purchasesWithEvent, {
    required TicketPurchaseQuery query,
    @Default(false) bool hasReachedMax,
    DioException? error,
  }) = _Loaded;
}
