part of 'event_detail_cubit.dart';

@freezed
class EventDetailState with _$EventDetailState {
  const factory EventDetailState.loading() = _Loading;
  const factory EventDetailState.loaded(EventModel event) = _Loaded;
  const factory EventDetailState.error(
    Exception exception,
  ) = _Error;
}
