import 'package:freezed_annotation/freezed_annotation.dart';

part 'new_auth_model.freezed.dart';
part 'new_auth_model.g.dart';

@freezed
class NewAuthModel with _$NewAuthModel {
  const factory NewAuthModel({
    required String accessToken,
    String? refreshToken,
  }) = _NewAuthModel;

  factory NewAuthModel.fromJson(Map<String, dynamic> json) =>
      _$NewAuthModelFromJson(json);
}
