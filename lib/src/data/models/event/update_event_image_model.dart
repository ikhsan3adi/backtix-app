import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_event_image_model.freezed.dart';
part 'update_event_image_model.g.dart';

typedef UpdateEventImageEntity = ({
  File? file,
  UpdateEventImageModel eventImage,
  String? oldImageUrl,
});

@freezed
class UpdateEventImageModel with _$UpdateEventImageModel {
  const UpdateEventImageModel._();

  const factory UpdateEventImageModel({
    num? id,
    String? description,
    @Default(false) bool withImage,
    @Default(false) bool delete,
  }) = _UpdateEventImageModel;

  factory UpdateEventImageModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateEventImageModelFromJson(json);
}
