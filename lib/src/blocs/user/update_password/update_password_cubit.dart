import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/data/repositories/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_password_cubit.freezed.dart';
part 'update_password_state.dart';

class UpdatePasswordCubit extends Cubit<UpdatePasswordState> {
  final UserRepository _userRepository;

  UpdatePasswordCubit(this._userRepository)
      : super(const UpdatePasswordState.initial());

  Future<void> updateUserPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(const UpdatePasswordState.loading());

    final result = await _userRepository.updateUserPassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    return result.fold(
      (e) => emit(UpdatePasswordState.failed(e)),
      (user) => emit(UpdatePasswordState.success(user)),
    );
  }
}
