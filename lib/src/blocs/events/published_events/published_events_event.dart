part of 'published_events_bloc.dart';

@freezed
class PublishedEventsEvent with _$PublishedEventsEvent {
  const factory PublishedEventsEvent.getPublishedEvents(
    EventQuery query, {
    bool? isUserLocationSet,
    @Default(false) bool? refreshNearbyEvents,
  }) = GetPublishedEvents;

  const factory PublishedEventsEvent.getMorePublishedEvents() = _GetMore;
}
