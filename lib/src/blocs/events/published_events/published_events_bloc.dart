import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/models/event/event_query.dart';
import 'package:backtix_app/src/data/repositories/event_repository.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'published_events_bloc.freezed.dart';
part 'published_events_event.dart';
part 'published_events_state.dart';

class PublishedEventsBloc
    extends HydratedBloc<PublishedEventsEvent, PublishedEventsState> {
  final EventRepository _eventRepository;

  PublishedEventsBloc(this._eventRepository) : super(const _Initial()) {
    on<GetPublishedEvents>(_getPublishedEvents);
    on<_GetMore>(_getMorePublishedEvents);
  }

  Future<void> _getPublishedEvents(
    GetPublishedEvents event,
    Emitter<PublishedEventsState> emit,
  ) async {
    final (
      previousPublishedEvents,
      previousNearbyEvents,
    ) = state.maybeMap(
      loaded: (state) => (state.events, state.nearbyEvents),
      orElse: () => (<EventModel>[], <EventModel>[]),
    );

    emit(PublishedEventsState.loading(
      refreshNearbyEvents: event.refreshNearbyEvents,
    ));

    final bool refreshNearbyEvents = (event.isUserLocationSet ?? false) &&
        (event.refreshNearbyEvents ?? false);

    final result = await Future.wait([
      _eventRepository.getPublishedEvents(event.query),
      if (refreshNearbyEvents) _eventRepository.getNearbyPublishedEvents(),
    ]);

    return result[0].fold(
      (e) {
        return emit(PublishedEventsState.loaded(
          previousPublishedEvents,
          previousNearbyEvents,
          error: e,
          query: event.query,
          refreshNearbyEvents: event.refreshNearbyEvents,
        ));
      },
      (events) {
        final nearbyEvents =
            refreshNearbyEvents ? result[1].toNullable() ?? [] : <EventModel>[];

        return emit(PublishedEventsState.loaded(
          events,
          nearbyEvents,
          query: event.query,
          refreshNearbyEvents: event.refreshNearbyEvents,
        ));
      },
    );
  }

  Future<void> _getMorePublishedEvents(
    _GetMore event,
    Emitter<PublishedEventsState> emit,
  ) async {
    final (
      previousPublishedEvents,
      previousNearbyEvents,
      query,
      hasReachedMax,
    ) = state.maybeMap(
      loaded: (state) => (
        state.events,
        state.nearbyEvents,
        state.query,
        state.hasReachedMax ?? false,
      ),
      orElse: () => (<EventModel>[], <EventModel>[], const EventQuery(), false),
    );

    final newQueries = query.copyWith(
      page: hasReachedMax ? query.page : query.page + 1,
    );

    final result = await _eventRepository.getPublishedEvents(newQueries);

    return result.fold(
      (e) {
        return emit(PublishedEventsState.loaded(
          previousPublishedEvents,
          previousNearbyEvents,
          error: e,
          query: newQueries,
          hasReachedMax: true,
        ));
      },
      (newPublishedEvents) {
        return emit(PublishedEventsState.loaded(
          [...previousPublishedEvents, ...newPublishedEvents],
          previousNearbyEvents,
          query: newQueries,
          hasReachedMax: newPublishedEvents.isEmpty,
        ));
      },
    );
  }

  @override
  PublishedEventsState? fromJson(Map<String, dynamic> json) {
    final events =
        (json['events'] as List).map((e) => EventModel.fromJson(e)).toList();
    final nearbyEvents = (json['nearbyEvents'] as List)
        .map((e) => EventModel.fromJson(e))
        .toList();

    return PublishedEventsState.loaded(
      events,
      nearbyEvents,
      query: const EventQuery(),
    );
  }

  @override
  Map<String, dynamic>? toJson(PublishedEventsState state) {
    return {
      'events': state.maybeMap(
        loaded: (state) =>
            state.events.take(20).map((e) => e.toJson()).toList(),
        orElse: () => <Map<String, dynamic>>[],
      ),
      'nearbyEvents': state.maybeMap(
        loaded: (state) =>
            state.nearbyEvents.take(5).map((e) => e.toJson()).toList(),
        orElse: () => <Map<String, dynamic>>[],
      ),
    };
  }
}
