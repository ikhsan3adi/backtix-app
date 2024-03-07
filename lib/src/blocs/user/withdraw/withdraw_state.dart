part of 'withdraw_cubit.dart';

@freezed
class WithdrawState with _$WithdrawState {
  const factory WithdrawState.initial() = _Initial;
  const factory WithdrawState.loading() = _Loading;
  const factory WithdrawState.loaded(
    UserBalanceModel userBalance,
    num adminFee,
  ) = _Loaded;
  const factory WithdrawState.success(
    WithdrawRequestModel withdrawRequest,
  ) = _Success;
  const factory WithdrawState.failed(Exception exception) = _Failed;
}
