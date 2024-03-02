import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:backtix_app/src/data/repositories/ticket_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_ticket_cubit.freezed.dart';
part 'verify_ticket_state.dart';

class VerifyTicketCubit extends Cubit<VerifyTicketState> {
  final TicketRepository _ticketRepository;

  VerifyTicketCubit(this._ticketRepository)
      : super(const VerifyTicketState.initial());

  Future<void> validateTicket({
    required String uid,
    required String eventId,
  }) async {
    emit(const VerifyTicketState.loading());

    final result = await _ticketRepository.validateTicketPurchase(
      uid: uid,
      eventId: eventId,
    );

    return result.fold(
      (err) => emit(VerifyTicketState.failed(err)),
      (ticket) => emit(VerifyTicketState.success(ticket)),
    );
  }

  Future<void> useTicket({required String uid, required String eventId}) async {
    emit(const VerifyTicketState.loading());

    final result = await _ticketRepository.useTicketPurchase(
      uid: uid,
      eventId: eventId,
    );

    return result.fold(
      (err) => emit(VerifyTicketState.failed(err)),
      (ticket) => emit(VerifyTicketState.success(ticket)),
    );
  }
}
