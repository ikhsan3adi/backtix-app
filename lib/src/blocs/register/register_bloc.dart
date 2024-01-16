import 'package:backtix_app/src/data/models/auth/new_auth_model.dart';
import 'package:backtix_app/src/data/models/auth/register_user_model.dart';
import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/data/services/remote/auth_service.dart';
import 'package:backtix_app/src/data/services/remote/google_auth_service.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_bloc.freezed.dart';
part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthService _authService;
  final GoogleAuthService _googleAuthService;

  RegisterBloc(this._authService, this._googleAuthService)
      : super(const _Initial()) {
    on<_RegisterUser>((event, emit) async {
      await TaskEither.tryCatch(
        () async {
          emit(const RegisterState.loading());
          final response =
              await _authService.registerUser(event.registerUserModel);

          emit(RegisterState.success(response.data));
        },
        (error, _) => emit(RegisterState.error(error as DioException)),
      ).run();
    });
    on<_GoogleSignUp>((event, emit) async {
      emit(const RegisterState.loading());
      final result = await _googleAuthService.signInOrSignUp();

      result.fold(
        (e) => emit(RegisterState.error(e)),
        (authOrUser) => authOrUser.fold(
          (auth) => emit(
            RegisterState.success(
              null,
              auth: auth,
              isUserAlreadyRegistered: true,
            ),
          ),
          (newUser) => emit(RegisterState.success(newUser)),
        ),
      );
    });
  }
}
