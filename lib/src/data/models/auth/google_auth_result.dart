import 'package:backtix_app/src/data/models/auth/new_auth_model.dart';
import 'package:backtix_app/src/data/models/user/user_balance_model.dart';
import 'package:backtix_app/src/data/models/user/user_group_enum.dart';
import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'google_auth_result.freezed.dart';
part 'google_auth_result.g.dart';

@freezed
class GoogleAuthResult with _$GoogleAuthResult {
  const GoogleAuthResult._();

  const factory GoogleAuthResult({
    required bool isNewUser,
    String? accessToken,
    String? refreshToken,
    @Default([UserGroup.user]) List<UserGroup> groups,
    String? provider,
    String? id,
    String? username,
    String? fullname,
    String? email,
    String? image,
    bool? activated,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    UserBalanceModel? balance,
  }) = _GoogleAuthResult;

  Either<NewAuthModel, UserModel> getAuthOrNewUser() {
    if (isNewUser) {
      return Right(
        UserModel(
          id: id!,
          username: username!,
          fullname: fullname!,
          email: email!,
          activated: activated!,
          groups: groups,
          balance: balance,
          image: image,
          provider: provider,
          createdAt: createdAt!,
          updatedAt: updatedAt!,
          deletedAt: deletedAt,
        ),
      );
    }
    return Left(
      NewAuthModel(
        accessToken: accessToken!,
        refreshToken: refreshToken,
      ),
    );
  }

  factory GoogleAuthResult.fromJson(Map<String, dynamic> json) =>
      _$GoogleAuthResultFromJson(json);
}
