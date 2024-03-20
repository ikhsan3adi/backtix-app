// ignore_for_file: deprecated_member_use_from_same_package

import 'package:backtix_app/src/blocs/notifications/notifications_cubit.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/data/models/notification/notification_model.dart';

class InfoNotificationsCubit extends NotificationsCubit {
  InfoNotificationsCubit(super.repository);

  @override
  Duration get interval => Constant.longInterval;

  @override
  void getNotifications() async {
    emit(const NotificationsState.loading());

    previouslastUpdated = lastUpdated;
    lastUpdated = DateTime.now();
    final result = await repository.getInfoNotifications(page: 0);

    return result.fold(
      (e) => emit(NotificationsState.loaded([], exception: e)),
      (notifications) {
        return emit(NotificationsState.loaded(
          notifications,
          lastUpdated: lastUpdated,
        ));
      },
    );
  }

  @override
  Future<void> getNewNotifications() async {
    previouslastUpdated = lastUpdated;
    final (previousData, page, hasReachedMax) = state.maybeMap(
      loaded: (state) => (state.notifications, state.page, state.hasReachedMax),
      orElse: () => (<NotificationModel>[], 0, false),
    );

    final result = await repository.getImportantNotifications(
      from: lastUpdated,
    );
    lastUpdated = DateTime.now();

    return result.fold(
      (_) {},
      (newNotifications) {
        return emit(NotificationsState.loaded(
          [...newNotifications, ...previousData],
          lastUpdated: lastUpdated,
          page: page,
          hasReachedMax: hasReachedMax,
        ));
      },
    );
  }

  @override
  Future<void> getMoreNotifications() async {
    if (!state.isLoaded) return;
    final currentState = state.mapOrNull(loaded: (s) => s)!;

    previouslastUpdated = lastUpdated;

    final (previousData, hasReachedMax) = (
      currentState.notifications,
      currentState.hasReachedMax,
    );

    final newPage = hasReachedMax ? currentState.page : currentState.page + 1;

    final result = await repository.getInfoNotifications(
      skip: previousData.length,
      to: lastUpdated,
    );

    return result.fold(
      (e) => emit(currentState.copyWith(
        notifications: previousData,
        exception: e,
        hasReachedMax: true,
      )),
      (notifications) => emit(currentState.copyWith(
        notifications: [...previousData, ...notifications],
        page: newPage,
        hasReachedMax: notifications.isEmpty,
      )),
    );
  }
}
