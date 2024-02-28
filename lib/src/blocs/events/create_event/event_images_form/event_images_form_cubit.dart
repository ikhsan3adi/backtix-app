import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_images_form_cubit.freezed.dart';
part 'event_images_form_state.dart';

class EventImagesFormCubit extends Cubit<EventImagesFormState> {
  EventImagesFormCubit() : super(const EventImagesFormState());

  static const int maxCount = 10;

  void addImages(List<File> imageFiles) {
    return emit(state.copyWith(
      images: [
        ...state.images,
        ...imageFiles.map((e) => (file: e, description: null)),
      ]..take(maxCount),
    ));
  }

  void changeImage(int index, {required File imageFile}) {
    return emit(state.copyWith(
      images: [...state.images]..replaceRange(
          index,
          index + 1,
          [(file: imageFile, description: state.images[index].description)],
        ),
    ));
  }

  void removeImage(int index) {
    return emit(state.copyWith(
      images: [...state.images]..removeAt(index),
    ));
  }

  void changeDescription(int index, {String? description}) {
    final trimmed = description?.trim();
    final desc = trimmed == '' ? null : trimmed;
    return emit(state.copyWith(
      images: [...state.images]..replaceRange(
          index,
          index + 1,
          [(file: state.images[index].file, description: desc)],
        ),
    ));
  }
}
