import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_image_model.freezed.dart';
part 'event_image_model.g.dart';

@freezed
class EventImageModel with _$EventImageModel {
  const factory EventImageModel({
    required int id,
    @Default('') String description,
    required String image,
  }) = _EventImageModel;

  factory EventImageModel.fromJson(Map<String, dynamic> json) =>
      _$EventImageModelFromJson(json);
}
