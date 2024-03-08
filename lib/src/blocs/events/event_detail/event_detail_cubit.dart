import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/repositories/event_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_detail_cubit.freezed.dart';
part 'event_detail_state.dart';

class EventDetailCubit extends Cubit<EventDetailState> {
  final EventRepository _eventRepository;

  EventDetailCubit(this._eventRepository)
      : super(const EventDetailState.loading());

  Future<void> getPublishedEventDetail(String id) async {
    emit(const EventDetailState.loading());

    final result = await _eventRepository.getPublishedEventDetail(id);

    return result.fold(
      (err) => emit(EventDetailState.error(err)),
      (event) => emit(EventDetailState.loaded(event)),
    );
  }

  Future<void> getMyEventDetail(String id) async {
    emit(const EventDetailState.loading());

    final result = await _eventRepository.getMyEventDetail(id);

    return result.fold(
      (err) => emit(EventDetailState.error(err)),
      (event) => emit(EventDetailState.loaded(event)),
    );
  }
}
