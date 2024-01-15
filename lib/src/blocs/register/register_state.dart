part of 'register_bloc.dart';

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState.initial() = _Initial;
  const factory RegisterState.loading() = _Loading;
  const factory RegisterState.success(
    UserModel? user, {
    NewAuthModel? auth,
    @Default(false) bool isUserAlreadyRegistered,
  }) = _Success;
  const factory RegisterState.error(Exception exception) = _Error;
}
