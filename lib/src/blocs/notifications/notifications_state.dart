part of 'notifications_cubit.dart';

@freezed
class NotificationsState with _$NotificationsState {
  const NotificationsState._();
  const factory NotificationsState.initial() = _Initial;
  const factory NotificationsState.loading() = _Loading;
  const factory NotificationsState.loaded(
    List<NotificationModel> notifications, {
    @Deprecated('Use skip query param') @Default(0) int page,
    DateTime? lastUpdated,
    @Default(false) bool hasReachedMax,
    Exception? exception,
  }) = _Loaded;
  bool get isLoaded => this is _Loaded;
}
