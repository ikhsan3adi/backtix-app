part of 'register_bloc.dart';

@freezed
class RegisterEvent with _$RegisterEvent {
  const factory RegisterEvent.registerUser(
    RegisterUserModel registerUserModel,
  ) = _RegisterUser;

  const factory RegisterEvent.googleSignUp() = _GoogleSignUp;
}
