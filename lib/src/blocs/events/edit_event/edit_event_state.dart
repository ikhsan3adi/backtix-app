part of 'edit_event_bloc.dart';

@freezed
class EditEventState with _$EditEventState {
  const factory EditEventState.initial() = _Initial;
  const factory EditEventState.loading() = _Loading;
  const factory EditEventState.loaded(
    EventModel? event, {
    Exception? exception,
  }) = _Loaded;
  const factory EditEventState.success(EventModel event) = _Success;
}
