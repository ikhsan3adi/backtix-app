import 'package:backtix_app/src/data/models/ticket/new_ticket_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_model.dart';
import 'package:backtix_app/src/data/models/ticket/update_ticket_model.dart';
import 'package:backtix_app/src/data/repositories/ticket_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'upsert_ticket_cubit.freezed.dart';
part 'upsert_ticket_state.dart';

class UpsertTicketCubit extends Cubit<UpsertTicketState> {
  final TicketRepository _ticketRepository;

  UpsertTicketCubit(this._ticketRepository)
      : super(const UpsertTicketState.initial());

  Future<void> createNewTicket(
    String eventId, {
    required NewTicketModel ticket,
  }) async {
    emit(const UpsertTicketState.loading());

    final result = await _ticketRepository.addNewTicket(eventId, ticket);

    return result.fold(
      (err) => emit(UpsertTicketState.error(err)),
      (ticket) => emit(UpsertTicketState.success(ticket)),
    );
  }

  Future<void> updateTicket(
    String ticketId, {
    required UpdateTicketModel ticket,
  }) async {
    emit(const UpsertTicketState.loading());

    final result = await _ticketRepository.updateTicket(ticketId, ticket);

    return result.fold(
      (err) => emit(UpsertTicketState.error(err)),
      (ticket) => emit(UpsertTicketState.success(ticket)),
    );
  }

  Future<void> deleteTicket(String ticketId) async {
    emit(const UpsertTicketState.loading());

    final result = await _ticketRepository.deleteTicket(ticketId);

    return result.fold(
      (err) => emit(UpsertTicketState.error(err)),
      (ticket) => emit(UpsertTicketState.success(ticket)),
    );
  }
}
