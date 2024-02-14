import 'package:backtix_app/src/data/models/ticket/ticket_purchase_query.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchases_by_event_model.dart';
import 'package:backtix_app/src/data/repositories/ticket_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_ticket_purchases_bloc.freezed.dart';
part 'my_ticket_purchases_event.dart';
part 'my_ticket_purchases_state.dart';

class MyTicketPurchasesBloc
    extends Bloc<MyTicketPurchasesEvent, MyTicketPurchasesState> {
  final TicketRepository _ticketRepository;

  MyTicketPurchasesBloc(this._ticketRepository) : super(const _Initial()) {
    on<_Get>(_getMyTicketPurchases);
    on<_GetMore>(_getMoreTicketPurchases);
  }

  Future<void> _getMyTicketPurchases(
    _Get event,
    Emitter<MyTicketPurchasesState> emit,
  ) async {
    final previousPurchases = state.maybeMap(
      loaded: (state) => state.purchasesWithEvent,
      orElse: () => <TicketPurchasesByEventModel>[],
    );

    emit(const MyTicketPurchasesState.loading());

    final result = await _ticketRepository.getMyTicketPurchases(event.query);

    return result.fold(
      (e) {
        return emit(MyTicketPurchasesState.loaded(
          previousPurchases,
          error: e,
          query: event.query,
        ));
      },
      (purchases) {
        return emit(MyTicketPurchasesState.loaded(
          purchases,
          query: event.query,
        ));
      },
    );
  }

  Future<void> _getMoreTicketPurchases(
    _GetMore event,
    Emitter<MyTicketPurchasesState> emit,
  ) async {
    if (state is! _Loaded) return;

    final (previousPurchases, query, hasReachedMax) = state.maybeMap(
      loaded: (state) => (
        state.purchasesWithEvent,
        state.query,
        state.hasReachedMax ?? false,
      ),
      orElse: () {
        return (
          <TicketPurchasesByEventModel>[],
          const TicketPurchaseQuery(),
          false
        );
      },
    );

    final newQueries = query.copyWith(
      page: hasReachedMax ? query.page : query.page + 1,
    );

    final result = await _ticketRepository.getMyTicketPurchases(newQueries);

    return result.fold(
      (e) {
        return emit(MyTicketPurchasesState.loaded(
          previousPurchases,
          error: e,
          query: newQueries,
          hasReachedMax: true,
        ));
      },
      (newPurchases) {
        return emit(MyTicketPurchasesState.loaded(
          [...previousPurchases, ...newPurchases],
          query: newQueries,
          hasReachedMax: newPurchases.isEmpty,
        ));
      },
    );
  }
}
