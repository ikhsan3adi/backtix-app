part of 'published_event_detail_cubit.dart';

@freezed
class PublishedEventDetailState with _$PublishedEventDetailState {
  const factory PublishedEventDetailState.loading() = _Loading;
  const factory PublishedEventDetailState.loaded(EventModel event) = _Loaded;
  const factory PublishedEventDetailState.error(
    DioException exception,
  ) = _Error;
}
