import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/models/event/new_event_model.dart';
import 'package:backtix_app/src/data/repositories/event_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_event_bloc.freezed.dart';
part 'create_event_event.dart';
part 'create_event_state.dart';

class CreateEventBloc extends Bloc<CreateEventEvent, CreateEventState> {
  final EventRepository _eventRepository;

  CreateEventBloc(this._eventRepository) : super(const _Initial()) {
    on<_CreateEvent>(_createEvent);
  }

  Future<void> _createEvent(
    _CreateEvent event,
    Emitter<CreateEventState> emit,
  ) async {
    emit(const CreateEventState.loading());

    final result = await _eventRepository.createNewEvent(event.newEvent);

    return result.fold(
      (err) => emit(CreateEventState.error(err)),
      (event) => emit(CreateEventState.success(event)),
    );
  }
}
