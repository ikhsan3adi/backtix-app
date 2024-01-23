part of 'published_events_bloc.dart';

@freezed
class PublishedEventsState with _$PublishedEventsState {
  const factory PublishedEventsState.initial() = _Initial;
  const factory PublishedEventsState.loading({
    @Default(true) bool? refreshNearbyEvents,
  }) = _Loading;
  const factory PublishedEventsState.loaded(
    List<EventModel> events,
    List<EventModel> nearbyEvents, {
    required EventQuery query,
    @Default(false) bool? hasReachedMax,
    DioException? error,
    @Default(false) bool? refreshNearbyEvents,
  }) = PublishedEventsLoaded;
}
