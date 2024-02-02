part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.authenticate({required NewAuthModel newAuth}) =
      _AddAuthentication;
  const factory AuthEvent.refreshAuthentication() = _RefreshAuthentication;
  const factory AuthEvent.removeAuthentication() = _RemoveAuthentication;

  /// refresh user detail
  const factory AuthEvent.updateUserDetails({
    UserModel? user,
  }) = _UpdateUserDetails;
}
