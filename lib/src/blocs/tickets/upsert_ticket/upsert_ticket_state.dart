part of 'upsert_ticket_cubit.dart';

@freezed
class UpsertTicketState with _$UpsertTicketState {
  const UpsertTicketState._();

  const factory UpsertTicketState.initial() = _Initial;
  const factory UpsertTicketState.loading() = _Loading;
  const factory UpsertTicketState.success(TicketModel ticket) = _Success;
  const factory UpsertTicketState.error(Exception exception) = _Error;

  bool get isLoading => this is _Loading;
}
