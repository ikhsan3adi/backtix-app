import 'package:backtix_app/src/data/models/user/user_balance_model.dart';
import 'package:backtix_app/src/data/models/user/user_group_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    @Default([UserGroup.user]) List<UserGroup> groups,
    String? provider,
    required String id,
    required String username,
    required String fullname,
    required String email,
    String? image,
    required bool activated,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    UserBalanceModel? balance,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
