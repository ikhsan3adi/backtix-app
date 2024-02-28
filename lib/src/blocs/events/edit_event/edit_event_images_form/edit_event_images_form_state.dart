part of 'edit_event_images_form_cubit.dart';

@freezed
class EditEventImagesFormState with _$EditEventImagesFormState {
  const factory EditEventImagesFormState({
    @Default([]) List<UpdateEventImageEntity> images,
  }) = _EditEventImagesFormState;
}
