import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/data/repositories/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reset_password_cubit.freezed.dart';
part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final UserRepository _userRepository;

  ResetPasswordCubit(this._userRepository)
      : super(const ResetPasswordState.initial());

  Future<void> requestPasswordReset() async {
    emit(const ResetPasswordState.loading());

    final result = await _userRepository.requestPasswordReset();

    return result.fold(
      (e) => emit(ResetPasswordState.error(e)),
      (_) => emit(const ResetPasswordState.initial()),
    );
  }

  Future<void> passwordReset({
    required String resetCode,
    required String newPassword,
  }) async {
    emit(const ResetPasswordState.loading());

    final result = await _userRepository.passwordReset(
      resetCode: resetCode,
      newPassword: newPassword,
    );

    return result.fold(
      (e) => emit(ResetPasswordState.error(e)),
      (user) => emit(ResetPasswordState.success(user)),
    );
  }
}
