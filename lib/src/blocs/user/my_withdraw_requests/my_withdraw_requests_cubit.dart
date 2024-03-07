import 'package:backtix_app/src/data/models/withdraw/withdraw_request_model.dart';
import 'package:backtix_app/src/data/models/withdraw/withdraw_status_enum.dart';
import 'package:backtix_app/src/data/repositories/balance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_withdraw_requests_cubit.freezed.dart';
part 'my_withdraw_requests_state.dart';

class MyWithdrawRequestsCubit extends Cubit<MyWithdrawRequestsState> {
  final BalanceRepository _balanceRepository;

  MyWithdrawRequestsCubit(this._balanceRepository)
      : super(const MyWithdrawRequestsState.initial());

  Future<void> getMyWithdrawRequests(WithdrawStatus? status) async {
    final previousData = state.maybeMap(
      loaded: (state) => state.withdraws,
      orElse: () => <WithdrawRequestModel>[],
    );

    emit(const MyWithdrawRequestsState.loading());

    final result = await _balanceRepository.getMyWithdrawRequests(
      status: status,
    );

    return result.fold(
      (e) => emit(MyWithdrawRequestsState.loaded(
        previousData,
        exception: e,
        status: status,
      )),
      (withdraws) => emit(MyWithdrawRequestsState.loaded(
        withdraws,
        status: status,
      )),
    );
  }

  Future<void> getMoreMyWithdrawRequests() async {
    if (state is! _Loaded) return;

    final (previousData, status, page) = state.maybeMap(
      loaded: (state) => (
        state.withdraws,
        state.status,
        state.hasReachedMax ? state.page : state.page + 1,
      ),
      orElse: () => (<WithdrawRequestModel>[], null, 0),
    );

    if (status == null) return;

    final result = await _balanceRepository.getMyWithdrawRequests(
      page: page,
      status: status,
    );

    return result.fold(
      (e) => emit(MyWithdrawRequestsState.loaded(
        previousData,
        exception: e,
        status: status,
        page: page,
        hasReachedMax: true,
      )),
      (withdraws) => emit(MyWithdrawRequestsState.loaded(
        [...previousData, ...withdraws],
        status: status,
        page: page,
        hasReachedMax: withdraws.isEmpty,
      )),
    );
  }
}
