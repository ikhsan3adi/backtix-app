import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_query.dart';
import 'package:backtix_app/src/data/repositories/ticket_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_ticket_sales_cubit.freezed.dart';
part 'event_ticket_sales_state.dart';

class EventTicketSalesCubit extends Cubit<EventTicketSalesState> {
  final TicketRepository _ticketRepository;

  EventTicketSalesCubit(this._ticketRepository)
      : super(const EventTicketSalesState.initial());

  Future<void> getTicketSales(String eventId, TicketPurchaseQuery query) async {
    final previousPurchases = state.maybeMap(
      loaded: (state) => state.purchases,
      orElse: () => <TicketPurchaseModel>[],
    );

    emit(const EventTicketSalesState.loading());

    final result = await _ticketRepository.getTicketPurchasesByEvent(
      eventId,
      query,
    );

    return result.fold(
      (e) => emit(EventTicketSalesState.loaded(
        previousPurchases,
        exception: e,
        eventId: eventId,
        query: query,
      )),
      (purchases) => emit(EventTicketSalesState.loaded(
        purchases,
        eventId: eventId,
        query: query,
      )),
    );
  }

  Future<void> getMoreTicketSales() async {
    if (state is! _Loaded) return;

    final (previousPurchases, query, hasReachedMax) = state.maybeMap(
      loaded: (state) => (
        state.purchases,
        state.query,
        state.hasReachedMax,
      ),
      orElse: () => (<TicketPurchaseModel>[], null, false),
    );

    final String eventId = (state as _Loaded).eventId;

    if (query == null) return;

    final newQueries = query.copyWith(
      page: hasReachedMax ? query.page : query.page + 1,
    );

    final result = await _ticketRepository.getTicketPurchasesByEvent(
      eventId,
      newQueries,
    );

    return result.fold(
      (e) => emit(EventTicketSalesState.loaded(
        previousPurchases,
        exception: e,
        query: newQueries,
        eventId: eventId,
        hasReachedMax: true,
      )),
      (purchases) => emit(EventTicketSalesState.loaded(
        [...previousPurchases, ...purchases],
        query: newQueries,
        eventId: eventId,
        hasReachedMax: purchases.isEmpty,
      )),
    );
  }
}
