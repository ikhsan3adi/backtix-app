import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_user_model.freezed.dart';

@freezed
class UpdateUserModel with _$UpdateUserModel {
  const UpdateUserModel._();

  const factory UpdateUserModel({
    String? username,
    String? fullname,
    String? email,
    String? password,
    File? image,
    bool? deleteImage,
    String? location,
    double? latitude,
    double? longitude,
  }) = _UpdateUserModel;
}
