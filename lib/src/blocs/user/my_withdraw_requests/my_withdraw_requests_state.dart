part of 'my_withdraw_requests_cubit.dart';

@freezed
class MyWithdrawRequestsState with _$MyWithdrawRequestsState {
  const factory MyWithdrawRequestsState.initial() = _Initial;
  const factory MyWithdrawRequestsState.loading() = _Loading;
  const factory MyWithdrawRequestsState.loaded(
    List<WithdrawRequestModel> withdraws, {
    WithdrawStatus? status,
    @Default(0) int page,
    @Default(false) bool hasReachedMax,
    Exception? exception,
  }) = _Loaded;
}
