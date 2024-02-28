import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/models/event/update_event_model.dart';
import 'package:backtix_app/src/data/repositories/event_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_event_bloc.freezed.dart';
part 'edit_event_event.dart';
part 'edit_event_state.dart';

class EditEventBloc extends Bloc<EditEventEvent, EditEventState> {
  final EventRepository _eventRepository;

  EditEventBloc(this._eventRepository) : super(const _Initial()) {
    on<_Init>(_init);
    on<_UpdateEvent>(_updateEvent);
  }

  Future<void> _init(_Init event, Emitter<EditEventState> emit) async {
    emit(const EditEventState.loading());

    final result = await _eventRepository.getMyEventDetail(event.eventId);

    return result.fold(
      (err) => emit(EditEventState.loaded(null, exception: err)),
      (event) => emit(EditEventState.loaded(event)),
    );
  }

  Future<void> _updateEvent(
    _UpdateEvent event,
    Emitter<EditEventState> emit,
  ) async {
    if (state is! _Loaded) return;

    final prevState = state as _Loaded;

    emit(const EditEventState.loading());

    final result = await _eventRepository.updateEvent(
      event.eventId,
      event.updatedEvent,
    );

    return result.fold(
      (err) => emit(EditEventState.loaded(prevState.event, exception: err)),
      (event) => emit(EditEventState.success(event)),
    );
  }
}
