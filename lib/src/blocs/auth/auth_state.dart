part of 'auth_bloc.dart';

enum AuthRefreshStatus { refreshing, done }

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;

  const factory AuthState.authenticated({
    required UserModel user,
    required NewAuthModel auth,
    @Default(AuthRefreshStatus.done) AuthRefreshStatus? status,
  }) = _Authenticated;

  const factory AuthState.unauthenticated({
    Exception? error,
  }) = _Unauthenticated;
}
