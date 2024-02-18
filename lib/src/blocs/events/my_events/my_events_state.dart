part of 'my_events_bloc.dart';

@freezed
class MyEventsState with _$MyEventsState {
  const factory MyEventsState.initial() = _Initial;
  const factory MyEventsState.loading() = _Loading;
  const factory MyEventsState.loaded(
    List<EventModel> events, {
    required EventQuery query,
    @Default(false) bool hasReachedMax,
    Exception? exception,
  }) = _Loaded;
}
