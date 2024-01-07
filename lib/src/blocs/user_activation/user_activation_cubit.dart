import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/data/services/remote/auth_service.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_activation_cubit.freezed.dart';
part 'user_activation_state.dart';

class UserActivationCubit extends Cubit<UserActivationState> {
  final AuthService _authService;

  UserActivationCubit(this._authService)
      : super(const UserActivationState.initial());

  Future<void> requestActivation() async {
    try {
      emit(const UserActivationState.loading());
      await _authService.requestActivationOtp();

      return emit(const UserActivationState.initial());
    } on DioException catch (e) {
      return emit(UserActivationState.error(e));
    }
  }

  Future<void> activateUser({required String otp}) async {
    try {
      emit(const UserActivationState.loading());
      final response = await _authService.activateUser(otp);
      return emit(UserActivationState.success(response.data));
    } on DioException catch (e) {
      return emit(UserActivationState.error(e));
    }
  }
}
