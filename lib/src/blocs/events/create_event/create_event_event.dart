part of 'create_event_bloc.dart';

@freezed
class CreateEventEvent with _$CreateEventEvent {
  const factory CreateEventEvent.createNewEvent(
    NewEventModel newEvent,
  ) = _CreateEvent;
}
