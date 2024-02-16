part of 'event_search_cubit.dart';

@freezed
class EventSearchState with _$EventSearchState {
  const factory EventSearchState.initial() = _Initial;
  const factory EventSearchState.loading() = _Loading;
  const factory EventSearchState.loaded(
    List<EventModel> events, {
    required EventQuery query,
    @Default(false) bool hasReachedMax,
    DioException? error,
  }) = _Loaded;
}
