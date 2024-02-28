import 'package:backtix_app/src/data/models/ticket/ticket_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_query.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchases_by_ticket_model.dart';
import 'package:backtix_app/src/data/repositories/ticket_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_sales_cubit.freezed.dart';
part 'ticket_sales_state.dart';

class TicketSalesCubit extends Cubit<TicketSalesState> {
  final TicketRepository _ticketRepository;

  TicketSalesCubit(this._ticketRepository)
      : super(const TicketSalesState.initial());

  Future<void> getTicketSales(
    String ticketId,
    TicketPurchaseQuery query,
  ) async {
    final previousPurchases = state.maybeMap(
      loaded: (state) => state.purchasesWithTicket,
      orElse: () => TicketPurchasesByTicketModel(
        ticket: TicketModel.dummyTicket,
      ),
    );

    emit(const TicketSalesState.loading());

    final result = await _ticketRepository.getTicketPurchasesByTicket(
      ticketId,
      query,
    );

    return result.fold(
      (e) => emit(TicketSalesState.loaded(
        previousPurchases,
        exception: e,
        ticketId: ticketId,
        query: query,
      )),
      (purchasesWithTicket) => emit(TicketSalesState.loaded(
        purchasesWithTicket,
        ticketId: ticketId,
        query: query,
      )),
    );
  }

  Future<void> getMoreTicketSales() async {
    if (state is! _Loaded) return;

    final (previousPurchases, query, hasReachedMax) = state.maybeMap(
      loaded: (state) => (
        state.purchasesWithTicket,
        state.query,
        state.hasReachedMax,
      ),
      orElse: () => (
        TicketPurchasesByTicketModel(ticket: TicketModel.dummyTicket),
        null,
        false,
      ),
    );

    if (query == null) return;

    final String ticketId = (state as _Loaded).ticketId;

    final newQueries = query.copyWith(
      page: hasReachedMax ? query.page : query.page + 1,
    );

    final result = await _ticketRepository.getTicketPurchasesByTicket(
      ticketId,
      newQueries,
    );

    return result.fold(
      (e) => emit(TicketSalesState.loaded(
        previousPurchases,
        exception: e,
        query: newQueries,
        ticketId: ticketId,
        hasReachedMax: true,
      )),
      (purchasesWithTicket) => emit(TicketSalesState.loaded(
        purchasesWithTicket.copyWith(
          purchases: [
            ...previousPurchases.purchases,
            ...purchasesWithTicket.purchases
          ],
        ),
        query: newQueries,
        ticketId: ticketId,
        hasReachedMax: purchasesWithTicket.purchases.isEmpty,
      )),
    );
  }
}
