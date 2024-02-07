import 'package:backtix_app/src/blocs/tickets/create_ticket_order/create_ticket_order_cubit.dart';
import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/models/purchase/transaction_model.dart';
import 'package:backtix_app/src/data/repositories/event_repository.dart';
import 'package:backtix_app/src/data/repositories/ticket_repository.dart';
import 'package:backtix_app/src/data/services/remote/payment_service.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_purchase_bloc.freezed.dart';
part 'ticket_purchase_event.dart';
part 'ticket_purchase_state.dart';

class TicketPurchaseBloc
    extends Bloc<TicketPurchaseEvent, TicketPurchaseState> {
  final TicketRepository _ticketRepository;
  final EventRepository _eventRepository;
  final PaymentService _paymentService;

  TicketPurchaseBloc(
    this._ticketRepository,
    this._eventRepository,
    this._paymentService,
  ) : super(const _Initial()) {
    on<_Init>(_init);
    on<_CreateOrder>(_createOrder);
  }

  Future<void> _init(
    _Init event,
    Emitter<TicketPurchaseState> emit,
  ) async {
    emit(const TicketPurchaseState.loading());

    final result = await _eventRepository.getPublishedEventDetail(
      event.eventId,
    );

    return result.fold(
      (e) => emit(TicketPurchaseState.loaded(null, error: e)),
      (event) => emit(TicketPurchaseState.loaded(event)),
    );
  }

  Future<void> _createOrder(
    _CreateOrder event,
    Emitter<TicketPurchaseState> emit,
  ) async {
    final previousState = state.mapOrNull(loaded: (s) => s);
    if (previousState == null) return;

    final result = await _ticketRepository.createTicketOrder(
      event.order.toModel,
    );

    return result.fold(
      (e) => emit(TicketPurchaseState.loaded(null, error: e)),
      (orderResult) async {
        if (orderResult.transaction.status == TransactionStatus.pending) {
          final result = await _paymentService.startPaymentFlow(
            orderResult.transaction,
          );

          return emit(TicketPurchaseState.loaded(
            previousState.event,
            orderSuccess: result,
          ));
        }

        return emit(TicketPurchaseState.loaded(
          previousState.event,
          orderSuccess: true,
        ));
      },
    );
  }
}
