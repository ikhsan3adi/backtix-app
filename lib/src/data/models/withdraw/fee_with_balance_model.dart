import 'package:backtix_app/src/data/models/user/user_balance_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fee_with_balance_model.freezed.dart';
part 'fee_with_balance_model.g.dart';

@freezed
class FeeWithBalanceModel with _$FeeWithBalanceModel {
  const factory FeeWithBalanceModel({
    required UserBalanceModel userBalance,
    required num fee,
  }) = _FeeWithBalanceModel;

  factory FeeWithBalanceModel.fromJson(Map<String, dynamic> json) =>
      _$FeeWithBalanceModelFromJson(json);
}
