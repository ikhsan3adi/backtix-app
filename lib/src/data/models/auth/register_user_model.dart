import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_user_model.freezed.dart';
part 'register_user_model.g.dart';

@freezed
class RegisterUserModel with _$RegisterUserModel {
  const factory RegisterUserModel({
    required String email,
    required String username,
    required String fullname,
    required String password,
  }) = _RegisterUserModel;

  factory RegisterUserModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterUserModelFromJson(json);
}
