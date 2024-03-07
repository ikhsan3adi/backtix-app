import 'package:backtix_app/src/data/models/withdraw/fee_with_balance_model.dart';
import 'package:backtix_app/src/data/models/withdraw/withdraw_request_model.dart';
import 'package:backtix_app/src/data/models/withdraw/withdraw_status_enum.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'balance_service.g.dart';

@RestApi()
abstract class BalanceService {
  factory BalanceService(Dio dio, {String? baseUrl}) = _BalanceService;

  @NoBody()
  @GET('balance/withdraw/my')
  Future<HttpResponse<FeeWithBalanceModel>> getUserBalanceWithAdminFee();

  @GET('withdraw/my')
  Future<HttpResponse<List<WithdrawRequestModel>>> getMyWithdrawRequests(
    @Query('page') int page,
    @Query('status') WithdrawStatus? status,
  );

  @POST('withdraw')
  Future<HttpResponse<WithdrawRequestModel>> requestWithdrawal(
    @Body() WithdrawRequestModel withdrawRequest,
  );
}
