part of 'user_activation_cubit.dart';

@freezed
class UserActivationState with _$UserActivationState {
  const factory UserActivationState.initial() = _Initial;
  const factory UserActivationState.loading() = _Loading;
  const factory UserActivationState.success(UserModel userModel) = _Success;
  const factory UserActivationState.error(DioException exception) = _Error;
}
