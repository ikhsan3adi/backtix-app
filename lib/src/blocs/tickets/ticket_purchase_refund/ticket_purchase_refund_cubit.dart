import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:backtix_app/src/data/repositories/ticket_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_purchase_refund_cubit.freezed.dart';
part 'ticket_purchase_refund_state.dart';

class TicketPurchaseRefundCubit extends Cubit<TicketPurchaseRefundState> {
  final TicketRepository _ticketRepository;

  TicketPurchaseRefundCubit(this._ticketRepository) : super(const _Initial());

  Future<void> refundTicketPurchase(String uid) async {
    emit(const TicketPurchaseRefundState.loading());

    final result = await _ticketRepository.refundTicketPurchase(uid);

    return result.fold(
      (err) => emit(TicketPurchaseRefundState.failed(err)),
      (purchase) => emit(TicketPurchaseRefundState.success(purchase)),
    );
  }

  Future<void> acceptTicketRefund(String uid) async {
    emit(const TicketPurchaseRefundState.loading());

    final result = await _ticketRepository.acceptTicketRefund(uid);

    return result.fold(
      (err) => emit(TicketPurchaseRefundState.failed(err)),
      (purchase) => emit(TicketPurchaseRefundState.success(purchase)),
    );
  }

  Future<void> rejectTicketRefund(String uid) async {
    emit(const TicketPurchaseRefundState.loading());

    final result = await _ticketRepository.rejectTicketRefund(uid);

    return result.fold(
      (err) => emit(TicketPurchaseRefundState.failed(err)),
      (purchase) => emit(TicketPurchaseRefundState.success(purchase)),
    );
  }
}
