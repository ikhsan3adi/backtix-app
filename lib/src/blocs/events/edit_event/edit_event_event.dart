part of 'edit_event_bloc.dart';

@freezed
class EditEventEvent with _$EditEventEvent {
  const factory EditEventEvent.init(String eventId) = _Init;
  const factory EditEventEvent.updateEvent(
    String eventId, {
    required UpdateEventModel updatedEvent,
  }) = _UpdateEvent;
}
