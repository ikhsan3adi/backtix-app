import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/blocs/login/login_bloc.dart';
import 'package:backtix_app/src/blocs/onboarding/onboarding_cubit.dart';
import 'package:backtix_app/src/blocs/register/register_bloc.dart';
import 'package:backtix_app/src/blocs/theme_mode/theme_mode_cubit.dart';
import 'package:backtix_app/src/blocs/user_activation/user_activation_cubit.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/core/network/dio_client.dart';
import 'package:backtix_app/src/core/network/interceptors/auth_interceptor.dart';
import 'package:backtix_app/src/core/network/interceptors/logging_interceptor.dart';
import 'package:backtix_app/src/data/repositories/user_repository.dart';
import 'package:backtix_app/src/data/services/remote/auth_service.dart';
import 'package:backtix_app/src/data/services/remote/user_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

Future<void> initializeDependencies() async {
  GetIt.I.registerSingleton<ThemeModeCubit>(ThemeModeCubit());
  GetIt.I.registerSingleton<OnboardingCubit>(OnboardingCubit());

  await initDio();

  GetIt.I.registerSingleton<AuthService>(AuthService(GetIt.I<Dio>()));
  GetIt.I.registerSingleton<UserService>(UserService(GetIt.I<Dio>()));

  GetIt.I.registerSingleton<UserRepository>(
    UserRepository(GetIt.I<UserService>()),
  );

  GetIt.I.registerSingleton<AuthBloc>(
    AuthBloc(
      GetIt.I<AuthService>(),
      GetIt.I<UserRepository>(),
      GetIt.I<DioClient>(),
    ),
  );

  GetIt.I<Dio>().interceptors.addAll([
    AuthInterceptor(dio: GetIt.I<Dio>(), authBloc: GetIt.I<AuthBloc>()),
    LoggingInterceptor(),
  ]);

  GetIt.I.registerFactory<LoginBloc>(() => LoginBloc(GetIt.I<AuthService>()));
  GetIt.I.registerFactory<RegisterBloc>(
    () => RegisterBloc(GetIt.I<AuthService>()),
  );
  GetIt.I.registerFactory<UserActivationCubit>(
    () => UserActivationCubit(GetIt.I<AuthService>()),
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
