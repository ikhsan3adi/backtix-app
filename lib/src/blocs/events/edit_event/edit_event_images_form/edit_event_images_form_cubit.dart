import 'dart:io';

import 'package:backtix_app/src/data/models/event/event_image_model.dart';
import 'package:backtix_app/src/data/models/event/update_event_image_model.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_event_images_form_cubit.freezed.dart';
part 'edit_event_images_form_state.dart';

class EditEventImagesFormCubit extends Cubit<EditEventImagesFormState> {
  EditEventImagesFormCubit() : super(const EditEventImagesFormState());

  static const int maxCount = 10;

  void init(List<EventImageModel> oldImages) {
    return emit(state.copyWith(
      images: oldImages
          .map((e) => (
                file: null,
                eventImage: UpdateEventImageModel(
                  id: e.id,
                  description: e.description,
                ),
                oldImageUrl: e.image,
              ))
          .toList(),
    ));
  }

  void addImages(List<File> imageFiles) {
    return emit(state.copyWith(
      images: [
        ...state.images,
        ...imageFiles.map((e) => (
              file: e,
              eventImage: const UpdateEventImageModel(withImage: true),
              oldImageUrl: null,
            ))
          ..take(maxCount),
      ]..take(maxCount * 2),
    ));
  }

  void changeImage(int index, {required File imageFile}) {
    final eventImage = state.images[index].eventImage;
    final oldImageUrl = state.images[index].oldImageUrl;
    return emit(state.copyWith(
      images: [...state.images]..replaceRange(
          index,
          index + 1,
          [
            (
              file: imageFile,
              eventImage: eventImage.copyWith(withImage: true),
              oldImageUrl: oldImageUrl,
            )
          ],
        ),
    ));
  }

  void removeImage(int index) {
    final eventImage = state.images[index].eventImage;
    // remove new image
    if (eventImage.id == null) {
      return emit(state.copyWith(images: [...state.images]..removeAt(index)));
    }
    // mark old image as deleted
    final oldImageUrl = state.images[index].oldImageUrl;
    final deletedImage = eventImage.copyWith(delete: true, withImage: false);
    return emit(state.copyWith(
      images: [...state.images]..replaceRange(
          index,
          index + 1,
          [(file: null, eventImage: deletedImage, oldImageUrl: oldImageUrl)],
        ),
    ));
  }

  void changeDescription(int index, {String? description}) {
    final file = state.images[index].file;
    final eventImage = state.images[index].eventImage;
    final oldImageUrl = state.images[index].oldImageUrl;

    final trimmed = description?.trim();
    final desc = trimmed == '' ? null : trimmed;

    return emit(state.copyWith(
      images: [...state.images]..replaceRange(
          index,
          index + 1,
          [
            (
              file: file,
              eventImage: eventImage.copyWith(description: desc),
              oldImageUrl: oldImageUrl,
            )
          ],
        ),
    ));
  }

  /// Revert from (picked file / deleted old image) to old image url
  void revertToOldImage(int index) {
    final eventImage = state.images[index].eventImage;
    // mark old image as not deleted
    final oldImageUrl = state.images[index].oldImageUrl;
    final deletedImage = eventImage.copyWith(delete: false);
    return emit(state.copyWith(
      images: [...state.images]..replaceRange(
          index,
          index + 1,
          [(file: null, eventImage: deletedImage, oldImageUrl: oldImageUrl)],
        ),
    ));
  }
}
