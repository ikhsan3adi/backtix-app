import 'package:backtix_app/src/blocs/notifications/notifications_cubit.dart';
import 'package:backtix_app/src/data/models/notification/notification_model.dart';

class InfoNotificationsCubit extends NotificationsCubit {
  InfoNotificationsCubit(super.repository);

  @override
  Duration get interval => const Duration(seconds: 300);

  @override
  void getNotifications() async {
    emit(const NotificationsState.loading());

    final result = await repository.getInfoNotifications();

    result.fold(
      (e) => emit(NotificationsState.loaded([], exception: e)),
      (notifications) {
        lastUpdated = DateTime.now();
        return emit(NotificationsState.loaded(notifications));
      },
    );
    return startRefreshing();
  }

  @override
  Future<void> getMoreNotifications() async {
    final (previousData, page, hasReachedMax) = state.maybeMap(
      loaded: (state) => (state.notifications, state.page, state.hasReachedMax),
      orElse: () => (<NotificationModel>[], 0, false),
    );

    final newPage = hasReachedMax ? page : page + 1;

    final result = await repository.getInfoNotifications(page: newPage);

    return result.fold(
      (e) => emit(NotificationsState.loaded(
        previousData,
        exception: e,
        hasReachedMax: true,
      )),
      (notifications) => emit(NotificationsState.loaded(
        [...previousData, ...notifications],
        page: newPage,
        hasReachedMax: notifications.isEmpty,
      )),
    );
  }

  @override
  Future<void> getNewNotifications() async {
    final (previousData, page, hasReachedMax) = state.maybeMap(
      loaded: (state) => (state.notifications, state.page, state.hasReachedMax),
      orElse: () => (<NotificationModel>[], 0, false),
    );

    final result = await repository.getInfoNotifications(
      from: lastUpdated,
    );

    return result.fold(
      (_) {},
      (newNotifications) {
        lastUpdated = DateTime.now();
        return emit(NotificationsState.loaded(
          [...newNotifications, ...previousData],
          page: page,
          hasReachedMax: hasReachedMax,
        ));
      },
    );
  }
}
