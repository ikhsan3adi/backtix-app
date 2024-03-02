part of 'verify_ticket_cubit.dart';

@freezed
class VerifyTicketState with _$VerifyTicketState {
  const VerifyTicketState._();

  const factory VerifyTicketState.initial() = _Initial;
  const factory VerifyTicketState.loading() = _Loading;
  const factory VerifyTicketState.success(
    TicketPurchaseModel ticketPurchase,
  ) = _Success;
  const factory VerifyTicketState.failed(Exception exception) = _Failed;

  bool get isLoading => this is _Loading;
}
