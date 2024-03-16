part of 'notifications_cubit.dart';

@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState.initial() = _Initial;
  const factory NotificationsState.loading() = _Loading;
  const factory NotificationsState.loaded(
    List<NotificationModel> notifications, {
    @Default(0) int page,
    @Default(false) bool hasReachedMax,
    Exception? exception,
  }) = _Loaded;
}
