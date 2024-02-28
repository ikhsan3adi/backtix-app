import 'dart:io';

import 'package:backtix_app/src/data/models/event/update_event_image_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_event_model.freezed.dart';

@freezed
class UpdateEventModel with _$UpdateEventModel {
  const UpdateEventModel._();

  const factory UpdateEventModel({
    String? name,
    String? description,
    DateTime? date,
    DateTime? endDate,
    String? location,
    double? latitude,
    double? longitude,
    @Default([]) List<String> categories,
    @Default([]) List<UpdateEventImageModel> images,
    @Default([]) List<File> eventImageFiles,
  }) = _UpdateEventModel;
}
