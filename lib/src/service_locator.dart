import 'dart:ui' show Color;

import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/blocs/auth/auth_helper.dart';
import 'package:backtix_app/src/blocs/events/create_event/create_event_bloc.dart';
import 'package:backtix_app/src/blocs/events/edit_event/edit_event_bloc.dart';
import 'package:backtix_app/src/blocs/events/event_detail/event_detail_cubit.dart';
import 'package:backtix_app/src/blocs/events/event_search/event_search_cubit.dart';
import 'package:backtix_app/src/blocs/events/my_events/my_events_bloc.dart';
import 'package:backtix_app/src/blocs/events/published_events/published_events_bloc.dart';
import 'package:backtix_app/src/blocs/login/login_bloc.dart';
import 'package:backtix_app/src/blocs/onboarding/onboarding_cubit.dart';
import 'package:backtix_app/src/blocs/register/register_bloc.dart';
import 'package:backtix_app/src/blocs/theme_mode/theme_mode_cubit.dart';
import 'package:backtix_app/src/blocs/tickets/event_ticket_sales/event_ticket_sales_cubit.dart';
import 'package:backtix_app/src/blocs/tickets/my_ticket_purchase_detail/my_ticket_purchase_detail_cubit.dart';
import 'package:backtix_app/src/blocs/tickets/my_ticket_purchases/my_ticket_purchases_bloc.dart';
import 'package:backtix_app/src/blocs/tickets/ticket_order/ticket_order_bloc.dart';
import 'package:backtix_app/src/blocs/tickets/ticket_purchase_refund/ticket_purchase_refund_cubit.dart';
import 'package:backtix_app/src/blocs/tickets/ticket_sales/ticket_sales_cubit.dart';
import 'package:backtix_app/src/blocs/tickets/upsert_ticket/upsert_ticket_cubit.dart';
import 'package:backtix_app/src/blocs/tickets/verify_ticket/verify_ticket_cubit.dart';
import 'package:backtix_app/src/blocs/user/my_withdraw_requests/my_withdraw_requests_cubit.dart';
import 'package:backtix_app/src/blocs/user/reset_password/reset_password_cubit.dart';
import 'package:backtix_app/src/blocs/user/update_password/update_password_cubit.dart';
import 'package:backtix_app/src/blocs/user/update_profile/update_profile_cubit.dart';
import 'package:backtix_app/src/blocs/user/withdraw/withdraw_cubit.dart';
import 'package:backtix_app/src/blocs/user_activation/user_activation_cubit.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/core/network/dio_client.dart';
import 'package:backtix_app/src/core/network/interceptors/auth_interceptor.dart';
import 'package:backtix_app/src/core/network/interceptors/logging_interceptor.dart';
import 'package:backtix_app/src/data/repositories/balance_repository.dart';
import 'package:backtix_app/src/data/repositories/event_repository.dart';
import 'package:backtix_app/src/data/repositories/ticket_repository.dart';
import 'package:backtix_app/src/data/repositories/user_repository.dart';
import 'package:backtix_app/src/data/services/remote/auth_service.dart';
import 'package:backtix_app/src/data/services/remote/balance_service.dart';
import 'package:backtix_app/src/data/services/remote/event_service.dart';
import 'package:backtix_app/src/data/services/remote/google_auth_service.dart';
import 'package:backtix_app/src/data/services/remote/payment_service.dart';
import 'package:backtix_app/src/data/services/remote/ticket_service.dart';
import 'package:backtix_app/src/data/services/remote/user_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> initializeDependencies() async {
  GetIt.I.registerSingletonAsync<PackageInfo>(
    () async => await PackageInfo.fromPlatform(),
  );

  GetIt.I.registerSingleton<ThemeModeCubit>(ThemeModeCubit());
  GetIt.I.registerSingleton<OnboardingCubit>(OnboardingCubit());

  await initDio();

  GetIt.I.registerSingleton<AuthService>(AuthService(GetIt.I<Dio>()));
  GetIt.I.registerLazySingleton<GoogleAuthService>(
    () => GoogleAuthService(GetIt.I<AuthService>()),
  );
  GetIt.I.registerSingleton<UserService>(UserService(GetIt.I<Dio>()));
  GetIt.I.registerLazySingleton<EventService>(
    () => EventService(GetIt.I<Dio>()),
  );
  GetIt.I.registerLazySingleton<TicketService>(
    () => TicketService(GetIt.I<Dio>()),
  );
  GetIt.I.registerLazySingleton<BalanceService>(
    () => BalanceService(GetIt.I<Dio>()),
  );

  await initPaymentService();

  GetIt.I.registerSingleton<UserRepository>(
    UserRepository(GetIt.I<UserService>()),
  );
  GetIt.I.registerLazySingleton<EventRepository>(
    () => EventRepository(GetIt.I<EventService>()),
  );
  GetIt.I.registerLazySingleton<TicketRepository>(
    () => TicketRepository(GetIt.I<TicketService>()),
  );
  GetIt.I.registerLazySingleton<BalanceRepository>(
    () => BalanceRepository(GetIt.I<BalanceService>()),
  );

  GetIt.I.registerSingleton<AuthBloc>(
    AuthBloc(
      GetIt.I<AuthService>(),
      GetIt.I<UserRepository>(),
      GetIt.I<DioClient>(),
      GetIt.I<GoogleAuthService>(),
    ),
  );

  GetIt.I<Dio>().interceptors.addAll([
    LoggingInterceptor(),
    AuthInterceptor(
      dio: GetIt.I<Dio>(),
      authHelper: AuthHelper(
        GetIt.I<AuthBloc>(),
        AuthService(
          Dio(BaseOptions(
            receiveDataWhenStatusError: true,
            contentType: Headers.jsonContentType,
          )),
          baseUrl: Constant.apiBaseUrl,
        ),
      ),
    ),
  ]);

  GetIt.I.registerFactory<LoginBloc>(
    () => LoginBloc(
      GetIt.I<AuthService>(),
      GetIt.I<GoogleAuthService>(),
    ),
  );
  GetIt.I.registerFactory<RegisterBloc>(
    () => RegisterBloc(
      GetIt.I<AuthService>(),
      GetIt.I<GoogleAuthService>(),
    ),
  );
  GetIt.I.registerFactory<UserActivationCubit>(
    () => UserActivationCubit(GetIt.I<AuthService>()),
  );

  GetIt.I.registerFactory<PublishedEventsBloc>(
    () => PublishedEventsBloc(GetIt.I<EventRepository>()),
  );
  GetIt.I.registerFactory<EventDetailCubit>(
    () => EventDetailCubit(GetIt.I<EventRepository>()),
  );
  GetIt.I.registerFactory<EventSearchCubit>(
    () => EventSearchCubit(GetIt.I<EventRepository>()),
  );
  GetIt.I.registerFactory<TicketOrderBloc>(
    () => TicketOrderBloc(
      GetIt.I<TicketRepository>(),
      GetIt.I<EventRepository>(),
      GetIt.I<PaymentService>(),
    ),
  );
  GetIt.I.registerFactory<MyTicketPurchasesBloc>(
    () => MyTicketPurchasesBloc(GetIt.I<TicketRepository>()),
  );
  GetIt.I.registerFactory<MyTicketPurchaseDetailCubit>(
    () => MyTicketPurchaseDetailCubit(GetIt.I<TicketRepository>()),
  );
  GetIt.I.registerFactory<TicketPurchaseRefundCubit>(
    () => TicketPurchaseRefundCubit(GetIt.I<TicketRepository>()),
  );

  GetIt.I.registerFactory<MyEventsBloc>(
    () => MyEventsBloc(GetIt.I<EventRepository>()),
  );
  GetIt.I.registerFactory<EventTicketSalesCubit>(
    () => EventTicketSalesCubit(GetIt.I<TicketRepository>()),
  );
  GetIt.I.registerFactory<TicketSalesCubit>(
    () => TicketSalesCubit(GetIt.I<TicketRepository>()),
  );
  GetIt.I.registerFactory<CreateEventBloc>(
    () => CreateEventBloc(GetIt.I<EventRepository>()),
  );
  GetIt.I.registerFactory<EditEventBloc>(
    () => EditEventBloc(GetIt.I<EventRepository>()),
  );
  GetIt.I.registerFactory<UpsertTicketCubit>(
    () => UpsertTicketCubit(GetIt.I<TicketRepository>()),
  );
  GetIt.I.registerFactory<VerifyTicketCubit>(
    () => VerifyTicketCubit(GetIt.I<TicketRepository>()),
  );
  GetIt.I.registerFactory<UpdateProfileCubit>(
    () => UpdateProfileCubit(GetIt.I<UserRepository>()),
  );
  GetIt.I.registerFactory<UpdatePasswordCubit>(
    () => UpdatePasswordCubit(GetIt.I<UserRepository>()),
  );
  GetIt.I.registerFactory<ResetPasswordCubit>(
    () => ResetPasswordCubit(GetIt.I<UserRepository>()),
  );
  GetIt.I.registerFactory<WithdrawCubit>(
    () => WithdrawCubit(GetIt.I<BalanceRepository>()),
  );
  GetIt.I.registerFactory<MyWithdrawRequestsCubit>(
    () => MyWithdrawRequestsCubit(GetIt.I<BalanceRepository>()),
  );
}

Future<void> initDio() async {
  final client = DioClient(
    baseUrl: Constant.apiBaseUrl,
    contentType: Headers.jsonContentType,
  );

  GetIt.I.registerSingleton<DioClient>(client);

  final Dio dio = GetIt.I<DioClient>().dio;

  GetIt.I.registerSingleton<Dio>(dio);
}

Future<void> initPaymentService() async {
  if (!PaymentService.isSdkSupported) {
    GetIt.I.registerSingleton<PaymentService>(PaymentService());
    return;
  }

  final config = MidtransConfig(
    clientKey: Constant.midtransClientKey,
    merchantBaseUrl: Constant.midtransMerchantBaseUrl,
    colorTheme: ColorTheme(
      colorPrimary: const Color(0xFF40C4FF),
      colorPrimaryDark: const Color(0xFF21767C),
      colorSecondary: const Color(0xFF40C4FF),
    ),
    enableLog: kDebugMode,
  );

  final sdk = await MidtransSDK.init(config: config);

  final service = PaymentService(midtransSdk: sdk);

  GetIt.I.registerSingleton<PaymentService>(service);
}
