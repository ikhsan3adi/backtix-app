import 'package:backtix_app/src/data/models/auth/new_auth_model.dart';
import 'package:backtix_app/src/data/services/remote/auth_service.dart';
import 'package:backtix_app/src/data/services/remote/google_auth_service.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_bloc.freezed.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService _authService;
  final GoogleAuthService _googleAuthService;

  LoginBloc(this._authService, this._googleAuthService)
      : super(const _Initial()) {
    on<_UsernameLogin>(_usernameLogin);
    on<_GoogleSignIn>(_googleSignIn);
  }

  Future<void> _usernameLogin(
    _UsernameLogin event,
    Emitter<LoginState> emit,
  ) async {
    await TaskEither.tryCatch(
      () async {
        emit(const LoginState.loading());
        final response = await _authService.usernameLogin(
          event.username,
          event.password,
        );
        emit(LoginState.success(response.data));
      },
      (error, _) => emit(LoginState.error(error as DioException)),
    ).run();
  }

  Future<void> _googleSignIn(
    _GoogleSignIn event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginState.loading());
    final result = await _googleAuthService.signInOrSignUp();

    result.fold(
      (e) => emit(LoginState.error(e)),
      (authOrUser) => authOrUser.fold(
        (auth) => emit(LoginState.success(auth)),
        // if user is new registered, repeat the request once again to get the tokens
        (newUser) => add(const LoginEvent.googleSignIn()),
      ),
    );
  }
}
