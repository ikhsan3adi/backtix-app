part of 'auth_bloc.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;

  const factory AuthState.authenticated({
    required UserModel user,
    required NewAuthModel auth,
  }) = _Authenticated;

  const factory AuthState.unauthenticated({
    Exception? exception,
  }) = _Unauthenticated;
}
