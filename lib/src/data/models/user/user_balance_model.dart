import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_balance_model.freezed.dart';
part 'user_balance_model.g.dart';

@freezed
class UserBalanceModel with _$UserBalanceModel {
  const factory UserBalanceModel({
    required num balance,
    required num revenue,
  }) = _Balance;

  factory UserBalanceModel.fromJson(Map<String, dynamic> json) =>
      _$UserBalanceModelFromJson(json);
}
