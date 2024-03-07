import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/data/models/withdraw/withdraw_from_enum.dart';
import 'package:backtix_app/src/data/models/withdraw/withdraw_status_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'withdraw_request_model.freezed.dart';
part 'withdraw_request_model.g.dart';

@freezed
class WithdrawRequestModel with _$WithdrawRequestModel {
  const factory WithdrawRequestModel({
    String? id,
    required num amount,
    num? fee,
    required String method,
    required String details,
    @Default(WithdrawFrom.balance) WithdrawFrom from,
    @Default(WithdrawStatus.pending) WithdrawStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? user,
  }) = _WithdrawRequestModel;

  factory WithdrawRequestModel.fromJson(Map<String, dynamic> json) =>
      _$WithdrawRequestModelFromJson(json);
}
