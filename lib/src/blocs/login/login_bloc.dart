import 'package:backtix_app/src/data/models/auth/new_auth_model.dart';
import 'package:backtix_app/src/data/services/remote/auth_service.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_bloc.freezed.dart';
part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService _authService;

  LoginBloc(this._authService) : super(const _Initial()) {
    on<_UsernameLogin>((event, emit) async {
      try {
        emit(const LoginState.loading());
        final response =
            await _authService.usernameLogin(event.username, event.password);

        return emit(LoginState.success(response.data));
      } on DioException catch (e) {
        return emit(LoginState.error(e));
      }
    });
    on<_GoogleSignIn>((event, emit) {
      // TODO: Google sign in
    });
  }
}
