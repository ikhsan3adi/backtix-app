import 'package:backtix_app/src/blocs/tickets/create_ticket_order/create_ticket_order_cubit.dart';
import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/models/purchase/transaction_model.dart';
import 'package:backtix_app/src/data/repositories/event_repository.dart';
import 'package:backtix_app/src/data/repositories/ticket_repository.dart';
import 'package:backtix_app/src/data/services/remote/payment_service.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_order_bloc.freezed.dart';
part 'ticket_order_event.dart';
part 'ticket_order_state.dart';

class TicketOrderBloc extends Bloc<TicketOrderEvent, TicketOrderState> {
  final TicketRepository _ticketRepository;
  final EventRepository _eventRepository;
  final PaymentService _paymentService;

  TicketOrderBloc(
    this._ticketRepository,
    this._eventRepository,
    this._paymentService,
  ) : super(const _Initial()) {
    on<_Init>(_init);
    on<_CreateOrder>(_createOrder);
  }

  Future<void> _init(
    _Init event,
    Emitter<TicketOrderState> emit,
  ) async {
    emit(const TicketOrderState.loading());

    final result = await _eventRepository.getPublishedEventDetail(
      event.eventId,
    );

    return result.fold(
      (e) => emit(TicketOrderState.loaded(null, error: e)),
      (event) => emit(TicketOrderState.loaded(event)),
    );
  }

  Future<void> _createOrder(
    _CreateOrder event,
    Emitter<TicketOrderState> emit,
  ) async {
    final previousState = state.mapOrNull(loaded: (s) => s);
    if (previousState == null) return;

    final result = await _ticketRepository.createTicketOrder(
      event.order.toModel,
    );

    return result.fold(
      (e) => emit(TicketOrderState.loaded(previousState.event, error: e)),
      (orderResult) async {
        if (orderResult.transaction.status == TransactionStatus.pending) {
          final result = await _paymentService.startPaymentFlow(
            orderResult.transaction,
          );

          return emit(TicketOrderState.loaded(
            previousState.event,
            orderSuccess: result,
          ));
        }

        return emit(TicketOrderState.loaded(
          previousState.event,
          orderSuccess: true,
        ));
      },
    );
  }
}
