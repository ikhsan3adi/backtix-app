import 'package:backtix_app/src/data/models/user/update_user_model.dart';
import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/data/models/user/user_with_auth_model.dart';
import 'package:backtix_app/src/data/repositories/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_profile_cubit.freezed.dart';
part 'update_profile_state.dart';

class UpdateProfileCubit extends Cubit<UpdateProfileState> {
  final UserRepository _userRepository;

  UpdateProfileCubit(this._userRepository)
      : super(const UpdateProfileState.initial());

  void init() async {
    emit(const UpdateProfileState.loading());

    final result = await _userRepository.getMyDetails();

    return result.fold(
      (e) => emit(UpdateProfileState.failed(e)),
      (user) => emit(UpdateProfileState.loaded(user)),
    );
  }

  Future<void> updateUserProfile(UpdateUserModel updatedUser) async {
    emit(const UpdateProfileState.loading());

    final result = await _userRepository.updateUser(updatedUser);

    return result.fold(
      (e) => emit(UpdateProfileState.failed(e)),
      (userWithAuth) => emit(UpdateProfileState.success(userWithAuth)),
    );
  }
}
