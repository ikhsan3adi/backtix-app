import 'package:backtix_app/src/data/models/auth/register_user_model.dart';
import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/data/services/remote/auth_service.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_bloc.freezed.dart';
part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthService _authService;

  RegisterBloc(this._authService) : super(const _Initial()) {
    on<_RegisterUser>((event, emit) async {
      try {
        emit(const RegisterState.loading());
        final response =
            await _authService.registerUser(event.registerUserModel);

        return emit(RegisterState.success(response.data));
      } on DioException catch (e) {
        return emit(RegisterState.error(e));
      }
    });
    on<_GoogleSignUp>((event, emit) async {
      // TODO: implement event handler
    });
  }
}
