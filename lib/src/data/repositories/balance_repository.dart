import 'package:backtix_app/src/data/models/withdraw/fee_with_balance_model.dart';
import 'package:backtix_app/src/data/models/withdraw/withdraw_request_model.dart';
import 'package:backtix_app/src/data/models/withdraw/withdraw_status_enum.dart';
import 'package:backtix_app/src/data/services/remote/balance_service.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class BalanceRepository {
  final BalanceService _balanceService;

  const BalanceRepository(this._balanceService);

  Future<Either<DioException, FeeWithBalanceModel>>
      getUserBalanceWithAdminFee() async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _balanceService.getUserBalanceWithAdminFee();
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, List<WithdrawRequestModel>>>
      getMyWithdrawRequests({
    int page = 0,
    WithdrawStatus? status,
  }) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _balanceService.getMyWithdrawRequests(
          page,
          status,
        );
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, WithdrawRequestModel>> requestWithdrawal(
    WithdrawRequestModel withdrawRequest,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _balanceService.requestWithdrawal(
          withdrawRequest,
        );
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }
}
