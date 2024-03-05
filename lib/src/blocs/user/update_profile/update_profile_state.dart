part of 'update_profile_cubit.dart';

@freezed
class UpdateProfileState with _$UpdateProfileState {
  const factory UpdateProfileState.initial() = _Initial;
  const factory UpdateProfileState.loading() = _Loading;
  const factory UpdateProfileState.loaded(UserModel user) = _Loaded;
  const factory UpdateProfileState.success(UserWithAuthModel userWithAuth) =
      _Success;
  const factory UpdateProfileState.failed(Exception exception) = _Failed;
}
