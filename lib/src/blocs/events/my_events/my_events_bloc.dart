import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/models/event/event_query.dart';
import 'package:backtix_app/src/data/repositories/event_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_events_bloc.freezed.dart';
part 'my_events_event.dart';
part 'my_events_state.dart';

class MyEventsBloc extends Bloc<MyEventsEvent, MyEventsState> {
  final EventRepository _eventRepository;

  MyEventsBloc(this._eventRepository) : super(const _Initial()) {
    on<_Get>(_getMyEvents);
    on<_GetMore>(_getMoreMyEvents);
  }

  Future<void> _getMyEvents(
    _Get event,
    Emitter<MyEventsState> emit,
  ) async {
    final previousEvents = state.maybeMap(
      loaded: (state) => state.events,
      orElse: () => <EventModel>[],
    );

    emit(const MyEventsState.loading());

    final result = await _eventRepository.getMyEvents(event.query);

    return result.fold(
      (e) {
        return emit(MyEventsState.loaded(
          previousEvents,
          error: e,
          query: event.query,
        ));
      },
      (events) {
        return emit(MyEventsState.loaded(
          events,
          query: event.query,
        ));
      },
    );
  }

  Future<void> _getMoreMyEvents(
    _GetMore event,
    Emitter<MyEventsState> emit,
  ) async {
    if (state is! _Loaded) return;

    final (previousEvents, query, hasReachedMax) = state.maybeMap(
      loaded: (state) => (
        state.events,
        state.query,
        state.hasReachedMax,
      ),
      orElse: () => (<EventModel>[], const EventQuery(), false),
    );

    final newQueries = query.copyWith(
      page: hasReachedMax ? query.page : query.page + 1,
    );

    final result = await _eventRepository.getMyEvents(newQueries);

    return result.fold(
      (e) {
        return emit(MyEventsState.loaded(
          previousEvents,
          error: e,
          query: newQueries,
          hasReachedMax: true,
        ));
      },
      (newEvents) {
        return emit(MyEventsState.loaded(
          [...previousEvents, ...newEvents],
          query: newQueries,
          hasReachedMax: newEvents.isEmpty,
        ));
      },
    );
  }
}
