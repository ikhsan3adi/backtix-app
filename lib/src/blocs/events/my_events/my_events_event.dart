part of 'my_events_bloc.dart';

@freezed
class MyEventsEvent with _$MyEventsEvent {
  const factory MyEventsEvent.getMyEvents(EventQuery query) = _Get;

  const factory MyEventsEvent.getMoreMyEvents() = _GetMore;
}
