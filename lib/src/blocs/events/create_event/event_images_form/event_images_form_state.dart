part of 'event_images_form_cubit.dart';

@freezed
class EventImagesFormState with _$EventImagesFormState {
  const factory EventImagesFormState({
    @Default([]) List<({File file, String? description})> images,
  }) = _EventImagesFormState;
}
