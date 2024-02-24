part of 'event_tickets_form_cubit.dart';

@freezed
class EventTicketsFormState with _$EventTicketsFormState {
  const factory EventTicketsFormState({
    @Default([]) List<NewTicketWithImage> tickets,
  }) = _EventTicketsFormState;
}
