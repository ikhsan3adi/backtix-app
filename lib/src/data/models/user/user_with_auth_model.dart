import 'package:backtix_app/src/data/models/auth/new_auth_model.dart';
import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_with_auth_model.freezed.dart';
part 'user_with_auth_model.g.dart';

@freezed
class UserWithAuthModel with _$UserWithAuthModel {
  const factory UserWithAuthModel({
    required UserModel user,
    NewAuthModel? newAuth,
  }) = _UserWithAuthModel;

  factory UserWithAuthModel.fromJson(Map<String, dynamic> json) =>
      _$UserWithAuthModelFromJson(json);
}
