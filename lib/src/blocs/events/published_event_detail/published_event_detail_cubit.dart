import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/repositories/event_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'published_event_detail_cubit.freezed.dart';
part 'published_event_detail_state.dart';

class PublishedEventDetailCubit extends Cubit<PublishedEventDetailState> {
  final EventRepository _eventRepository;

  PublishedEventDetailCubit(this._eventRepository)
      : super(const PublishedEventDetailState.loading());

  Future<void> getPublishedEventDetail(String id) async {
    emit(const PublishedEventDetailState.loading());

    final result = await _eventRepository.getPublishedEventDetail(id);

    return result.fold(
      (err) => emit(PublishedEventDetailState.error(err)),
      (event) => emit(PublishedEventDetailState.loaded(event)),
    );
  }

  Future<void> getMyEventDetail(String id) async {
    emit(const PublishedEventDetailState.loading());

    final result = await _eventRepository.getMyEventDetail(id);

    return result.fold(
      (err) => emit(PublishedEventDetailState.error(err)),
      (event) => emit(PublishedEventDetailState.loaded(event)),
    );
  }
}
