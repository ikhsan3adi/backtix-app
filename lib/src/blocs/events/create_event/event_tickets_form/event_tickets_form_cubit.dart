import 'dart:io';

import 'package:backtix_app/src/data/models/ticket/new_ticket_model.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_tickets_form_cubit.freezed.dart';
part 'event_tickets_form_state.dart';

class EventTicketsFormCubit extends Cubit<EventTicketsFormState> {
  EventTicketsFormCubit() : super(const EventTicketsFormState());

  static const int maxCount = 10;

  void addTicket(NewTicketWithImage ticketWithImage) {
    return emit(state.copyWith(
      tickets: [...state.tickets, ticketWithImage]..take(maxCount),
    ));
  }

  void updateTicket(int index, {NewTicketWithImage? ticketWithImage}) {
    final oldVal = state.tickets[index];
    return emit(state.copyWith(
      tickets: [...state.tickets]..replaceRange(
          index,
          index + 1,
          [ticketWithImage ?? oldVal],
        ),
    ));
  }

  void removeTicket(int index) {
    return emit(state.copyWith(tickets: [...state.tickets]..removeAt(index)));
  }
}
