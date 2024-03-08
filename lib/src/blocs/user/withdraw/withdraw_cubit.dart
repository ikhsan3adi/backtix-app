import 'package:backtix_app/src/data/models/user/user_balance_model.dart';
import 'package:backtix_app/src/data/models/withdraw/withdraw_request_model.dart';
import 'package:backtix_app/src/data/repositories/balance_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'withdraw_cubit.freezed.dart';
part 'withdraw_state.dart';

class WithdrawCubit extends Cubit<WithdrawState> {
  final BalanceRepository _balanceRepository;

  WithdrawCubit(this._balanceRepository) : super(const WithdrawState.initial());

  void init() async {
    emit(const WithdrawState.loading());

    final result = await _balanceRepository.getUserBalanceWithAdminFee();

    return result.fold(
      (e) => emit(WithdrawState.failed(e)),
      (data) => emit(WithdrawState.loaded(data.userBalance, data.fee)),
    );
  }

  Future<void> requestWithdrawal(WithdrawRequestModel withdrawRequest) async {
    emit(const WithdrawState.loading());

    final result = await _balanceRepository.requestWithdrawal(withdrawRequest);

    return result.fold(
      (e) => emit(WithdrawState.failed(e)),
      (result) => emit(WithdrawState.success(result)),
    );
  }
}
