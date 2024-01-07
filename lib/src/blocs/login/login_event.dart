part of 'login_bloc.dart';

@freezed
class LoginEvent with _$LoginEvent {
  const factory LoginEvent.usernamelogin({
    required String username,
    required String password,
  }) = _UsernameLogin;

  const factory LoginEvent.googleSignIn() = _GoogleSignIn;
}
