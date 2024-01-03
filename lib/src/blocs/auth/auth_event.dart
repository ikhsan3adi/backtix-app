part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.authenticate({required NewAuthModel newAuth}) =
      _AddAuthentication;
  const factory AuthEvent.refreshAuthentication() = _RefreshAuthentication;
  const factory AuthEvent.removeAuthentication() = _RemoveAuthentication;

  const factory AuthEvent.updateUserDetails({
    required UserModel user,
  }) = _UpdateUserDetails;
}
